import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';

class GetInstitutionsUseCase {
  const GetInstitutionsUseCase(this._repo);

  final InstitutionRepository _repo;

  Future<Either<Failure, List<Institution>>> call({
    required String userId,
    bool forceRefresh = false,
  }) {
    return _repo.getInstitutions(userId: userId, forceRefresh: forceRefresh);
  }
}
