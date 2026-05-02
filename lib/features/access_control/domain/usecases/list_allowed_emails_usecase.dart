import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/entities/allowed_email_entity.dart';
import 'package:financo/features/access_control/domain/repositories/access_control_repository.dart';

class ListAllowedEmailsUseCase {
  ListAllowedEmailsUseCase(this._repository);

  final AccessControlRepository _repository;

  Future<Either<Failure, List<AllowedEmailEntity>>> call() =>
      _repository.listAllowedEmails();
}
