import 'dart:async';

import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_version.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/check_for_update.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/clear_cached_updates.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/download_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/install_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/manage_update_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'update_event.dart';
part 'update_state.dart';

/// Orchestrates app update checks, internal APK downloads, cache cleanup, and installation.
class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final CheckForUpdate _checkForUpdate;
  final DownloadApk _downloadApk;
  final InstallApk _installApk;
  final ClearCachedUpdates _clearCachedUpdates;
  final ManageUpdatePermission _managePermission;
  final Duration _permissionPromptDelay;

  String _lastDownloadUrl = githubLatestApkUrl;

  UpdateBloc({
    required CheckForUpdate checkForUpdate,
    required DownloadApk downloadApk,
    required InstallApk installApk,
    required ClearCachedUpdates clearCachedUpdates,
    required ManageUpdatePermission managePermission,
    Duration permissionPromptDelay = const Duration(seconds: 5),
  })  : _checkForUpdate = checkForUpdate,
        _downloadApk = downloadApk,
        _installApk = installApk,
        _clearCachedUpdates = clearCachedUpdates,
        _managePermission = managePermission,
        _permissionPromptDelay = permissionPromptDelay,
        super(const UpdateInitial()) {
    on<UpdateCacheClearRequested>((_, __) => _clearCachedUpdates());
    on<UpdateCheckRequested>(_onCheckRequested);
    on<UpdateDeclined>(_onDeclined);
    on<UpdateDownloadRequested>(_onDownloadRequested);
    on<UpdateInstallRequested>(_onInstallRequested);
  }

  FutureOr<void> _onCheckRequested(
    UpdateCheckRequested event,
    Emitter<UpdateState> emit,
  ) async {
    final res = await _checkForUpdate();
    res.fold(
      (fail) => emit(UpdateNotice(fail.message)),
      (release) => emit(
        release != null ? UpdateAvailable(release) : const UpdateUpToDate(),
      ),
    );
  }

  FutureOr<void> _onDeclined(
    UpdateDeclined event,
    Emitter<UpdateState> emit,
  ) async {
    await _clearCachedUpdates();
    emit(const UpdateNotice(':('));
  }

  /// Downloads the release APK into internal cache with live progress updates.
  FutureOr<void> _onDownloadRequested(
    UpdateDownloadRequested event,
    Emitter<UpdateState> emit,
  ) async {
    _lastDownloadUrl = event.release.downloadUrl;
    emit(const UpdateDownloadInProgress(0));

    final result = await _downloadApk(
      DownloadApkParams(
        url: event.release.downloadUrl,
        onProgress: (progress) {
          if (!emit.isDone) {
            emit(UpdateDownloadInProgress(progress));
          }
        },
      ),
    );

    if (result.isLeft()) {
      await _clearCachedUpdates();
      if (!emit.isDone) {
        emit(
          const UpdateDownloadFailed("Impossibile scaricare l'aggiornamento"),
        );
      }
      return;
    }

    final apkPath = result.getOrElse((_) => '');
    if (!emit.isDone) {
      emit(
        UpdateDownloadCompleted(
          apkPath: apkPath,
          version: event.release.version,
        ),
      );
    }
  }

  /// Requests package-install permission and hands the cached APK to the OS installer.
  FutureOr<void> _onInstallRequested(
    UpdateInstallRequested event,
    Emitter<UpdateState> emit,
  ) async {
    final granted = await _ensurePermission(
      permission: UpdatePermission.installPackages,
      promptMessage:
          'Ti verrà ora chiesto di dare il permesso per installare il pacchetto di aggiornamento',
      deniedMessage:
          "Ma come no?! Mi serve il permesso per installare il pacchetto e aggiornare l'app",
      deniedDurationSeconds: 5,
      emit: emit,
    );
    if (!granted) {
      await _clearCachedUpdates();
      return;
    }

    final result = await _installApk(event.apkPath);
    result.fold(
      (failure) {
        final failedPath =
            failure is UpdateInstallFailure ? failure.apkPath : event.apkPath;
        final errorType = failure is UpdateInstallFailure
            ? failure.errorType
            : failure.message;
        emit(UpdateInstallFailed(
          errorType: errorType,
          apkPath: failedPath,
          downloadUrl: _lastDownloadUrl,
        ));
      },
      (_) => emit(const UpdateInstallCompleted()),
    );
  }

  /// Prompts the user if [permission] is missing, then requests it and notifies on denial.
  Future<bool> _ensurePermission({
    required UpdatePermission permission,
    required String promptMessage,
    required String deniedMessage,
    required int deniedDurationSeconds,
    required Emitter<UpdateState> emit,
  }) async {
    if (!await _managePermission.has(permission)) {
      emit(UpdateNotice(promptMessage, durationSeconds: 5));
      if (_permissionPromptDelay > Duration.zero) {
        await Future.delayed(_permissionPromptDelay);
      }
    }

    final req = await _managePermission(permission);
    final granted = req.fold((_) => false, (ok) => ok);
    if (!granted && !emit.isDone) {
      emit(UpdateNotice(deniedMessage, durationSeconds: deniedDurationSeconds));
    }
    return granted;
  }
}
