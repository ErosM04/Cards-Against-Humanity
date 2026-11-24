import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Checks whether a newer non-draft app release is available.
class CheckForUpdate implements UseCaseAsync<AppRelease?> {
  final UpdateRepository updateRepository;

  const CheckForUpdate({required this.updateRepository});

  @override
  Future<Either<Failure, AppRelease?>> call() =>
      updateRepository.checkForUpdate();
}
