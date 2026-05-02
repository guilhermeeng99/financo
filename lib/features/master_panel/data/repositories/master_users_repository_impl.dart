import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/master_panel/data/datasources/master_users_remote_datasource.dart';
import 'package:financo/features/master_panel/domain/repositories/master_users_repository.dart';

class MasterUsersRepositoryImpl implements MasterUsersRepository {
  MasterUsersRepositoryImpl({
    required MasterUsersRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final MasterUsersRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<UserEntity>>> listAllUsers() async {
    try {
      final users = await _remote.listAllUsers();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserAsAdmin(String targetUid) async {
    try {
      await _remote.deleteUserAsAdmin(targetUid);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }
}
