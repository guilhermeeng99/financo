import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/features/investing/data/models/snapshot_model.dart';
import 'package:financo/features/investing/data/repositories/snapshot_repository_impl.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SnapshotModel.fromEntity(SnapshotFactory.day()));
    registerFallbackValue(SnapshotFactory.day());
    registerFallbackValue(<Snapshot>[]);
  });

  late MockSnapshotRemoteDataSource remote;
  late MockInvestmentSnapshotsDao dao;
  late SnapshotRepositoryImpl repo;

  setUp(() {
    remote = MockSnapshotRemoteDataSource();
    dao = MockInvestmentSnapshotsDao();
    repo = SnapshotRepositoryImpl(remoteDataSource: remote, snapshotsDao: dao);
  });

  test('getSnapshots without forceRefresh reads only the cache', () async {
    when(
      () => dao.getSnapshots('user-1'),
    ).thenAnswer((_) async => [SnapshotFactory.day()]);

    final result = await repo.getSnapshots(userId: 'user-1');

    expect(result.isRight(), isTrue);
    verifyNever(() => remote.getSnapshots(userId: any(named: 'userId')));
  });

  test('getSnapshots with forceRefresh pulls remote, replaces cache', () async {
    when(() => remote.getSnapshots(userId: 'user-1')).thenAnswer(
      (_) async => [SnapshotModel.fromEntity(SnapshotFactory.day())],
    );
    when(() => dao.deleteAllSnapshots()).thenAnswer((_) async {});
    when(() => dao.insertAllSnapshots(any())).thenAnswer((_) async {});
    when(
      () => dao.getSnapshots('user-1'),
    ).thenAnswer((_) async => [SnapshotFactory.day()]);

    final result = await repo.getSnapshots(
      userId: 'user-1',
      forceRefresh: true,
    );

    expect(result.isRight(), isTrue);
    verify(() => remote.getSnapshots(userId: 'user-1')).called(1);
    verify(() => dao.deleteAllSnapshots()).called(1);
    verify(() => dao.insertAllSnapshots(any())).called(1);
  });

  test('recordSnapshot writes remote then upserts the cache', () async {
    final snapshot = SnapshotFactory.day();
    when(() => remote.upsertSnapshot(any())).thenAnswer((_) async {});
    when(() => dao.upsertSnapshot(any())).thenAnswer((_) async {});

    final result = await repo.recordSnapshot(snapshot);

    expect(result.isRight(), isTrue);
    verify(() => remote.upsertSnapshot(any())).called(1);
    verify(() => dao.upsertSnapshot(snapshot)).called(1);
  });

  test('maps a ServerException to a ServerFailure', () async {
    when(() => remote.upsertSnapshot(any())).thenThrow(const ServerException());

    final result = await repo.recordSnapshot(SnapshotFactory.day());

    expect(result.isLeft(), isTrue);
  });
}
