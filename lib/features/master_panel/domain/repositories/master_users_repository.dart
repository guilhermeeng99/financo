import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';

abstract class MasterUsersRepository {
  Future<Either<Failure, List<UserEntity>>> listAllUsers();
  Future<Either<Failure, void>> deleteUserAsAdmin(String targetUid);
}
