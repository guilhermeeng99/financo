import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/sync/sync_service.dart';
import 'package:financo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required UsersDao usersDao,
    required SyncService syncService,
  }) : _remote = remoteDataSource,
       _usersDao = usersDao,
       _syncService = syncService;

  final AuthRemoteDataSource _remote;
  final UsersDao _usersDao;
  final SyncService _syncService;

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.signIn(
        email: email,
        password: password,
      );
      await _usersDao.upsertUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _remote.signInWithGoogle();
      await _usersDao.upsertUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.signUp(
        name: name,
        email: email,
        password: password,
      );
      await _usersDao.upsertUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      await _syncService.clearLocalData();
      return const Right(null);
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remote.getCurrentUser();
      if (user != null) await _usersDao.upsertUser(user);
      return Right(user);
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;
}
