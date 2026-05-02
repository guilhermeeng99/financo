import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';

abstract class AccessControlRepository {
  Future<Either<Failure, bool>> isEmailAllowed(String email);
  Future<Either<Failure, List<AllowedEmailEntity>>> listAllowedEmails();
  Future<Either<Failure, void>> addAllowedEmail({
    required String email,
    String? note,
  });
  Future<Either<Failure, void>> removeAllowedEmail(String email);
}
