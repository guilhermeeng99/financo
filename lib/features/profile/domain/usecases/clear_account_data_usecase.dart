import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/profile/domain/repositories/profile_repository.dart';

class ClearAccountDataUseCase {
  ClearAccountDataUseCase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  Future<Either<Failure, void>> call(String userId) =>
      _repository.clearAccountData(userId);
}
