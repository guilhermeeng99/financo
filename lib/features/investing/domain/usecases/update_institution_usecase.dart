import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';

/// Updates an institution after validating a non-empty, unique name (excluding
/// the institution being edited).
class UpdateInstitutionUseCase {
  const UpdateInstitutionUseCase(this._repo);

  final InstitutionRepository _repo;

  Future<Either<Failure, Institution>> call(Institution institution) async {
    final name = institution.name.trim();
    if (name.isEmpty) return const Left(EmptyNameFailure());

    final listResult = await _repo.getInstitutions(userId: institution.userId);
    final failure = listResult.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) return Left(failure);

    final existing = listResult.getOrElse(() => const []);
    final isDuplicate = existing.any(
      (e) =>
          e.id != institution.id &&
          e.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (isDuplicate) return Left(DuplicateInstitutionNameFailure(name));

    return _repo.updateInstitution(institution.copyWith(name: name));
  }
}
