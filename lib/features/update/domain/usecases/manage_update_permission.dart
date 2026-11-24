import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase_param.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Checks and requests OS permissions needed for downloading and installing APK updates.
class ManageUpdatePermission implements UseCaseAsyncParam<bool, UpdatePermission> {
  final UpdateRepository updateRepository;

  const ManageUpdatePermission({required this.updateRepository});

  Future<bool> has(UpdatePermission permission) =>
      updateRepository.hasPermission(permission);

  @override
  Future<Either<Failure, bool>> call(UpdatePermission permission) =>
      updateRepository.requestPermission(permission);
}
