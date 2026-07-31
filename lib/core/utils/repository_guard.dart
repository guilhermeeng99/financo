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

/// Runs a CSV **preview** [body], mapping the two failure shapes every
/// importer shares: a malformed file surfaces the parser's own message as a
/// `ValidationFailure` (the user can act on "row 3: unknown column"), while
/// anything else becomes an opaque `ServerFailure` carrying [serverMessage].
///
/// Five importers (accounts, categories, transactions, investing assets,
/// investing transactions) had written this same try/catch by hand. The split
/// matters: swapping the two would either hide a fixable CSV problem behind a
/// generic error, or leak an internal exception message into the UI.
///
/// Example:
/// ```dart
/// Future<Either<Failure, AssetImportPreview>> preview(String csv) {
///   return guardCsvParse(
///     () async => _buildPreview(_parseCsv(csv)),
///     serverMessage: 'Failed to import assets.',
///   );
/// }
/// ```
Future<Either<Failure, T>> guardCsvParse<T>(
  Future<Either<Failure, T>> Function() body, {
  required String serverMessage,
}) async {
  try {
    return await body();
  } on FormatException catch (e) {
    return Left(ValidationFailure(e.message));
  } on Exception {
    return Left(ServerFailure(serverMessage));
  }
}
