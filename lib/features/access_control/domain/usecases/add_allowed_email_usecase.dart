import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/access_control/domain/repositories/access_control_repository.dart';

class AddAllowedEmailUseCase {
  AddAllowedEmailUseCase(this._repository);

  final AccessControlRepository _repository;

  Future<Either<Failure, void>> call({
    required String email,
    String? note,
  }) => _repository.addAllowedEmail(email: email, note: note);
}
