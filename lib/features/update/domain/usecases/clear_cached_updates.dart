import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Deletes cached update APKs from internal storage.
class ClearCachedUpdates implements UseCaseAsync<Unit> {
  final UpdateRepository updateRepository;

  const ClearCachedUpdates({required this.updateRepository});

  @override
  Future<Either<Failure, Unit>> call() =>
      updateRepository.clearCachedUpdates();
}
