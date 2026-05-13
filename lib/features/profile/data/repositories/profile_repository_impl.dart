import 'package:dartz/dartz.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required UsersDao usersDao,
    required AppDatabase database,
  }) : _remote = remoteDataSource,
       _usersDao = usersDao,
       _database = database;

  final ProfileRemoteDataSource _remote;
  final UsersDao _usersDao;
  final AppDatabase _database;

  @override
  Future<Either<Failure, UserEntity>> getProfile(String userId) async {
    try {
      final local = await _usersDao.getUser(userId);
      if (local != null) return Right(local);
      final user = await _remote.getProfile(userId);
      await _usersDao.upsertUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    try {
      await _remote.updateProfile(user);
      final model = UserModel.fromEntity(user);
      await _usersDao.upsertUser(model);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearAccountData(String userId) async {
    try {
      await _remote.wipeUserData(userId);
      await _database.clearAllTables();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
