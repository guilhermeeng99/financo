import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getProfile(String userId);

  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);

  /// Wipes every user-scoped document on the backend and clears the local
  /// cache. Idempotent — re-running after success is a no-op because the
  /// remote collections are already empty.
  Future<Either<Failure, void>> clearAccountData(String userId);
}
