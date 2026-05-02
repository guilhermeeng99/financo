import 'package:dartz/dartz.dart';
import 'package:financo/core/constants/access_control.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/data/datasources/access_control_remote_datasource.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';
import 'package:financo/features/access_control/domain/repositories/access_control_repository.dart';

class AccessControlRepositoryImpl implements AccessControlRepository {
  AccessControlRepositoryImpl({
    required AccessControlRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final AccessControlRemoteDataSource _remote;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Future<Either<Failure, bool>> isEmailAllowed(String email) async {
    try {
      final allowed = await _remote.isEmailAllowed(email);
      return Right(allowed);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AllowedEmailEntity>>> listAllowedEmails() async {
    try {
      final list = await _remote.listAllowedEmails();
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addAllowedEmail({
    required String email,
    String? note,
  }) async {
    final normalized = normalizeEmail(email);
    if (normalized.isEmpty || !_emailRegex.hasMatch(normalized)) {
      return const Left(ValidationFailure('Email inválido.'));
    }
    if (isMasterEmail(normalized)) {
      // Master is implicit — adding is a no-op but we surface a clear error
      // so the UI can communicate the situation.
      return const Left(ValidationFailure('O master já tem acesso.'));
    }
    try {
      await _remote.addAllowedEmail(email: normalized, note: note);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeAllowedEmail(String email) async {
    final normalized = normalizeEmail(email);
    if (isMasterEmail(normalized)) {
      // Defense in depth — UI hides the option, but rejecting here too
      // prevents accidental misuse via direct repository calls.
      return const Left(AuthFailure('Não é possível remover o master.'));
    }
    try {
      await _remote.removeAllowedEmail(normalized);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }
}
