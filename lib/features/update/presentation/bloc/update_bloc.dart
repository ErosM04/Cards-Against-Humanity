import 'dart:async';

import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/check_for_update.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/download_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/install_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/manage_update_permission.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/pick_and_install_apk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'update_event.dart';
part 'update_state.dart';

/// Orchestrates app update checks, APK downloads, OS permission prompts, and APK installation.
class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final CheckForUpdate _checkForUpdate;
  final DownloadApk _downloadApk;
  final InstallApk _installApk;
  final PickAndInstallApk _pickAndInstallApk;
  final ManageUpdatePermission _managePermission;
  final Duration _permissionPromptDelay;

  UpdateBloc({
    required CheckForUpdate checkForUpdate,
    required DownloadApk downloadApk,
    required InstallApk installApk,
    required PickAndInstallApk pickAndInstallApk,
    required ManageUpdatePermission managePermission,
    Duration permissionPromptDelay = const Duration(seconds: 5),
  })  : _checkForUpdate = checkForUpdate,
        _downloadApk = downloadApk,
        _installApk = installApk,
        _pickAndInstallApk = pickAndInstallApk,
        _managePermission = managePermission,
        _permissionPromptDelay = permissionPromptDelay,
        super(const UpdateInitial()) {
    on<UpdateCheckRequested>(_onCheckRequested);
    on<UpdateDeclined>((_, emit) => emit(const UpdateNotice(':(')));
    on<UpdateDownloadRequested>(_onDownloadRequested);
    on<UpdateInstallRequested>(_onInstallRequested);
    on<UpdateManualInstallRequested>(_onManualInstallRequested);
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

  FutureOr<void> _onDownloadRequested(
    UpdateDownloadRequested event,
    Emitter<UpdateState> emit,
  ) async {
    final granted = await _ensurePermission(
      permission: UpdatePermission.externalStorage,
      promptMessage:
          'Ti verrà ora chiesto di dare il permesso per accedere ai file del dispositivo',
      deniedMessage: 'Fottiti',
      deniedDurationSeconds: 2,
      emit: emit,
    );
    if (!granted) return;

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

    result.fold(
      (_) => emit(
        const UpdateDownloadFailed("Impossibile scaricare l'aggiornamento"),
      ),
      (apkPath) => emit(
        UpdateDownloadCompleted(
          apkPath: apkPath,
          version: event.release.version,
        ),
      ),
    );
  }

  FutureOr<void> _onInstallRequested(
    UpdateInstallRequested event,
    Emitter<UpdateState> emit,
  ) async {
    final granted = await _ensurePermission(
      permission: UpdatePermission.installPackages,
      promptMessage:
          'Ti verrà ora chiesto di dare il permesso per installare il pacchetto di aggiornamento',
      deniedMessage:
          "Ma come no? Cattivo! Vatti a installare l'update nella cartella Download",
      deniedDurationSeconds: 5,
      emit: emit,
    );
    if (!granted) return;

    final result = await _installApk(event.apkPath);
    result.fold(
      (failure) {
        if (failure is UpdateInstallFailure) {
          emit(UpdateInstallFailed(
            errorType: failure.errorType,
            apkPath: failure.apkPath,
          ));
        } else {
          emit(UpdateInstallFailed(
            errorType: failure.message,
            apkPath: event.apkPath,
          ));
        }
      },
      (_) => emit(const UpdateInstallCompleted()),
    );
  }

  FutureOr<void> _onManualInstallRequested(
    UpdateManualInstallRequested event,
    Emitter<UpdateState> emit,
  ) async {
    final result = await _pickAndInstallApk();
    result.fold(
      (failure) => emit(UpdateNotice(failure.message, durationSeconds: 5)),
      (_) => emit(const UpdateInstallCompleted()),
    );
  }

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
