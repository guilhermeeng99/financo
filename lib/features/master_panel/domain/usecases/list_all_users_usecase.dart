import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/master_panel/domain/repositories/master_users_repository.dart';

class ListAllUsersUseCase {
  ListAllUsersUseCase(this._repository);

  final MasterUsersRepository _repository;

  Future<Either<Failure, List<UserEntity>>> call() =>
      _repository.listAllUsers();
}
