import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';

/// Reads/writes investing custody institutions. Firestore-primary with a Drift
/// cache. See `docs/specs/institutions.md`.
abstract class InstitutionRepository {
  Future<Either<Failure, List<Institution>>> getInstitutions({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Institution>> createInstitution(Institution i);

  Future<Either<Failure, Institution>> updateInstitution(Institution i);

  Future<Either<Failure, void>> deleteInstitution(String id);
}
