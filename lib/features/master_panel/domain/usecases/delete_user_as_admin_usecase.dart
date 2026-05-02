import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/master_panel/domain/repositories/master_users_repository.dart';

class DeleteUserAsAdminUseCase {
  DeleteUserAsAdminUseCase(this._repository);

  final MasterUsersRepository _repository;

  Future<Either<Failure, void>> call(String targetUid) =>
      _repository.deleteUserAsAdmin(targetUid);
}
