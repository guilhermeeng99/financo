import 'package:dartz/dartz.dart';
import 'package:financo/core/cache/app_data_cache.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AppDataCache cache,
  }) : _remote = remoteDataSource,
       _cache = cache;

  final AuthRemoteDataSource _remote;
  final AppDataCache _cache;

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.signIn(email: email, password: password);
      _cache.currentUser = user;
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
      _cache.currentUser = user;
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
      _cache.currentUser = user;
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
      _cache.clear();
      return const Right(null);
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      if (_cache.currentUser != null) return Right(_cache.currentUser);
      final user = await _remote.getCurrentUser();
      _cache.currentUser = user;
      return Right(user);
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;
}
