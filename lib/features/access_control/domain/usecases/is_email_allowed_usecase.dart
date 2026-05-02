import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/repositories/access_control_repository.dart';

class IsEmailAllowedUseCase {
  IsEmailAllowedUseCase(this._repository);

  final AccessControlRepository _repository;

  Future<Either<Failure, bool>> call(String email) =>
      _repository.isEmailAllowed(email);
}
