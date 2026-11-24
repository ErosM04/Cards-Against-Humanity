import 'dart:convert';
import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/errors/exceptions.dart';
import 'package:cards_against_humanity/features/update/data/models/app_release_model.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

/// Contract for remote update operations (fetching release metadata and downloading APKs).
abstract interface class UpdateRemoteDataSource {
  /// Fetches and parses the latest GitHub release metadata.
  Future<AppReleaseModel> fetchLatestRelease();

  /// Downloads [url] to [destinationPath], reporting normalized progress to [onProgress].
  Future<void> downloadFile({
    required String url,
    required String destinationPath,
    void Function(double progress)? onProgress,
  });
}

/// HTTP and Dio implementation of [UpdateRemoteDataSource] for GitHub Releases.
class UpdateRemoteDataSourceImpl implements UpdateRemoteDataSource {
  final http.Client _httpClient;
  final Dio _dio;
  final String _latestReleaseUrl;

  UpdateRemoteDataSourceImpl({
    http.Client? httpClient,
    Dio? dio,
    String latestReleaseUrl = githubLatestReleaseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _dio = dio ?? Dio(),
        _latestReleaseUrl = latestReleaseUrl;

  @override
  Future<AppReleaseModel> fetchLatestRelease() async {
    int? statusCode;
    try {
      final response = await _httpClient.get(Uri.parse(_latestReleaseUrl));
      statusCode = response.statusCode;

      if (statusCode != 200) {
        throw UpdateException(
          "Errore di rete '$statusCode' durante la ricerca dell'aggiornamento",
        );
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return AppReleaseModel.fromJson(decoded);
    } on UpdateException {
      rethrow;
    } catch (_) {
      throw UpdateException(
        "Errore '${statusCode ?? ''}' durante la ricerca dell'aggiornamento",
      );
    }
  }

  @override
  Future<void> downloadFile({
    required String url,
    required String destinationPath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      await _dio.download(
        url,
        destinationPath,
        onReceiveProgress: (received, total) {
          if (onProgress != null && total > 0) {
            onProgress(received / total);
          }
        },
      );
    } catch (e) {
      throw UpdateException("Impossibile scaricare l'aggiornamento: $e");
    }
  }
}
