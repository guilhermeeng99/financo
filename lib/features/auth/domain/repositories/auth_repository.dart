import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Google-only sign-in. Returns `Left(AccessDeniedFailure)` if the
  /// authenticated email is not in the allowlist (the user is signed
  /// out before the failure is returned, so no dangling session remains).
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Stream of session changes after the allowlist gate. Emits `null`
  /// when the user is signed out OR when the session was force-revoked
  /// because they lost access.
  Stream<UserEntity?> get authStateChanges;
}
