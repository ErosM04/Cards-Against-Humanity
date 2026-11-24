import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase_param.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Parameters for downloading an update APK.
class DownloadApkParams {
  final String url;
  final String fileName;
  final void Function(double progress)? onProgress;

  const DownloadApkParams({
    required this.url,
    this.fileName = 'Cards_Against_Humanity',
    this.onProgress,
  });
}

/// Downloads the APK for a new release and returns its saved file path.
class DownloadApk implements UseCaseAsyncParam<String, DownloadApkParams> {
  final UpdateRepository updateRepository;

  const DownloadApk({required this.updateRepository});

  @override
  Future<Either<Failure, String>> call(DownloadApkParams param) =>
      updateRepository.downloadApk(
        url: param.url,
        fileName: param.fileName,
        onProgress: param.onProgress,
      );
}
