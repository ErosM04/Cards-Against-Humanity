import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase_param.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Installs the downloaded APK at the given file path.
class InstallApk implements UseCaseAsyncParam<Unit, String> {
  final UpdateRepository updateRepository;

  const InstallApk({required this.updateRepository});

  @override
  Future<Either<Failure, Unit>> call(String apkPath) =>
      updateRepository.installApk(apkPath);
}
