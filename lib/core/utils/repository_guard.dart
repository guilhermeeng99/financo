import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';

/// Runs a repository [body] and maps the result into the project's
/// `Either<Failure, T>` contract: success → `Right(value)`,
/// `ServerException` → `Left(ServerFailure)`.
///
/// Removes the try/catch boilerplate repeated in every repository CRUD
/// method. Use [guardServerVoid] for methods that return `void`.
///
/// Example:
/// ```dart
/// Future<Either<Failure, AccountEntity>> createAccount(AccountEntity a) {
///   return guardServer(() async {
///     final result = await _remote.createAccount(AccountModel.fromEntity(a));
///     await _dao.upsertAccount(result);
///     return result;
///   });
/// }
/// ```
Future<Either<Failure, T>> guardServer<T>(Future<T> Function() body) async {
  try {
    return Right(await body());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}

/// [guardServer] for `void`-returning repository methods (deletes, etc.).
Future<Either<Failure, void>> guardServerVoid(
  Future<void> Function() body,
) async {
  try {
    await body();
    return const Right(null);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
