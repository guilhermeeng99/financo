import 'package:dartz/dartz.dart';
import 'package:financo/core/database/daos/institutions_dao.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/utils/repository_guard.dart';
import 'package:financo/features/investing/data/datasources/institution_remote_datasource.dart';
import 'package:financo/features/investing/data/models/institution_model.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';

class InstitutionRepositoryImpl implements InstitutionRepository {
  InstitutionRepositoryImpl({
    required InstitutionRemoteDataSource remoteDataSource,
    required InstitutionsDao institutionsDao,
  }) : _remote = remoteDataSource,
       _dao = institutionsDao;

  final InstitutionRemoteDataSource _remote;
  final InstitutionsDao _dao;

  @override
  Future<Either<Failure, List<Institution>>> getInstitutions({
    required String userId,
    bool forceRefresh = false,
  }) {
    return guardServer(() async {
      if (forceRefresh) {
        final remote = await _remote.getInstitutions(userId: userId);
        await _dao.deleteAllInstitutions();
        if (remote.isNotEmpty) {
          await _dao.insertAllInstitutions(remote);
        }
      }
      return _dao.getInstitutions(userId);
    });
  }

  @override
  Future<Either<Failure, Institution>> createInstitution(Institution i) {
    return guardServer(() async {
      final result = await _remote.createInstitution(
        InstitutionModel.fromEntity(i),
      );
      await _dao.upsertInstitution(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, Institution>> updateInstitution(Institution i) {
    return guardServer(() async {
      final result = await _remote.updateInstitution(
        InstitutionModel.fromEntity(i),
      );
      await _dao.upsertInstitution(result);
      return result;
    });
  }

  @override
  Future<Either<Failure, void>> deleteInstitution(String id) {
    return guardServerVoid(() async {
      await _remote.deleteInstitution(id);
      await _dao.deleteInstitution(id);
    });
  }
}
