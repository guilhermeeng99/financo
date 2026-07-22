import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investing/data/models/institution_model.dart';
import 'package:financo/features/investing/data/repositories/institution_repository_impl.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      InstitutionModel.fromEntity(InstitutionFactory.nubank()),
    );
    registerFallbackValue(InstitutionFactory.nubank());
    registerFallbackValue(<Institution>[]);
  });

  late MockInstitutionRemoteDataSource remote;
  late MockInstitutionsDao dao;
  late InstitutionRepositoryImpl repo;

  setUp(() {
    remote = MockInstitutionRemoteDataSource();
    dao = MockInstitutionsDao();
    repo = InstitutionRepositoryImpl(
      remoteDataSource: remote,
      institutionsDao: dao,
    );
  });

  test('getInstitutions without forceRefresh reads only the cache', () async {
    when(
      () => dao.getInstitutions('user-1'),
    ).thenAnswer((_) async => [InstitutionFactory.nubank()]);

    final result = await repo.getInstitutions(userId: 'user-1');

    expect(result.isRight(), isTrue);
    verifyNever(() => remote.getInstitutions(userId: any(named: 'userId')));
  });

  test(
    'getInstitutions with forceRefresh pulls remote, replaces cache',
    () async {
      when(() => remote.getInstitutions(userId: 'user-1')).thenAnswer(
        (_) async => [InstitutionModel.fromEntity(InstitutionFactory.nubank())],
      );
      when(() => dao.deleteAllInstitutions()).thenAnswer((_) async {});
      when(() => dao.insertAllInstitutions(any())).thenAnswer((_) async {});
      when(
        () => dao.getInstitutions('user-1'),
      ).thenAnswer((_) async => [InstitutionFactory.nubank()]);

      final result = await repo.getInstitutions(
        userId: 'user-1',
        forceRefresh: true,
      );

      expect(result.isRight(), isTrue);
      verify(() => remote.getInstitutions(userId: 'user-1')).called(1);
      verify(() => dao.deleteAllInstitutions()).called(1);
      verify(() => dao.insertAllInstitutions(any())).called(1);
    },
  );

  test('createInstitution writes remote then upserts the cache', () async {
    final created = InstitutionModel.fromEntity(InstitutionFactory.nubank());
    when(
      () => remote.createInstitution(any()),
    ).thenAnswer((_) async => created);
    when(() => dao.upsertInstitution(any())).thenAnswer((_) async {});

    final result = await repo.createInstitution(InstitutionFactory.nubank());

    expect(result.isRight(), isTrue);
    verify(() => dao.upsertInstitution(created)).called(1);
  });

  test('deleteInstitution deletes remote then local', () async {
    when(
      () => remote.deleteInstitution('inst-nubank'),
    ).thenAnswer((_) async {});
    when(() => dao.deleteInstitution('inst-nubank')).thenAnswer((_) async {});

    final result = await repo.deleteInstitution('inst-nubank');

    expect(result.isRight(), isTrue);
    verify(() => remote.deleteInstitution('inst-nubank')).called(1);
    verify(() => dao.deleteInstitution('inst-nubank')).called(1);
  });

  test('maps a ServerException to a ServerFailure', () async {
    when(
      () => remote.getInstitutions(userId: 'user-1'),
    ).thenThrow(const ServerException());

    final result = await repo.getInstitutions(
      userId: 'user-1',
      forceRefresh: true,
    );

    expect(result.isLeft(), isTrue);
  });
}
