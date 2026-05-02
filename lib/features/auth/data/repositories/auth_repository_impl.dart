import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/sync/sync_service.dart';
import 'package:financo/features/access_control/domain/repositories/access_control_repository.dart';
import 'package:financo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required UsersDao usersDao,
    required SyncService syncService,
    required AccessControlRepository accessControlRepository,
  }) : _remote = remoteDataSource,
       _usersDao = usersDao,
       _syncService = syncService,
       _accessControl = accessControlRepository;

  final AuthRemoteDataSource _remote;
  final UsersDao _usersDao;
  final SyncService _syncService;
  final AccessControlRepository _accessControl;

  /// Runs the allowlist gate against the given user. On block: signs out
  /// (best-effort) and returns `Left(AccessDeniedFailure)`. On allow:
  /// returns `Right(user)`.
  ///
  /// On a failure of the gate check itself (e.g. Firestore unavailable)
  /// we return `Right(user)` — fail-open — so a transient outage does
  /// not lock everyone out. The next session tick re-evaluates.
  Future<Either<Failure, UserEntity>> _gate(UserEntity user) async {
    final check = await _accessControl.isEmailAllowed(user.email);
    return check.fold(
      (failure) async => Right(user),
      (allowed) async {
        if (allowed) return Right(user);
        // Best-effort sign out — even if it fails, the next stream tick
        // will re-evaluate and force the user back to the access screen.
        try {
          await _remote.signOut();
        } on Exception {
          // Swallow — already returning AccessDenied.
        }
        return Left(AccessDeniedFailure(user.email));
      },
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _remote.signInWithGoogle();
      final gated = await _gate(user);
      return gated.fold(
        (failure) async => Left(failure),
        (allowed) async {
          await _usersDao.upsertUser(allowed);
          return Right(allowed);
        },
      );
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
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remote.getCurrentUser();
      if (user == null) return const Right(null);
      final gated = await _gate(user);
      return gated.fold(
        (failure) async => Left(failure),
        (allowed) async {
          await _usersDao.upsertUser(allowed);
          return Right(allowed);
        },
      );
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges async* {
    await for (final user in _remote.authStateChanges) {
      if (user == null) {
        yield null;
        continue;
      }
      // Re-check the allowlist on every emission — covers the case where
      // master removes a friend's email while their session is live.
      final check = await _accessControl.isEmailAllowed(user.email);
      final blocked = check.fold((_) => false, (allowed) => !allowed);
      if (blocked) {
        try {
          await _remote.signOut();
        } on Exception {
          // Ignore — sign-out failure does not change the access decision.
        }
        yield null;
      } else {
        yield user;
      }
    }
  }
}
