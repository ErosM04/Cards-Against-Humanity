import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Prompts the user to manually pick an `.apk` file and launches installation.
class PickAndInstallApk implements UseCaseAsync<Unit> {
  final UpdateRepository updateRepository;

  const PickAndInstallApk({required this.updateRepository});

  @override
  Future<Either<Failure, Unit>> call() => updateRepository.pickAndInstallApk();
}
