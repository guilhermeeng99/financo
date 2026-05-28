import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/data/models/asset_holding_model.dart';
import 'package:financo/features/investments/data/repositories/asset_holding_repository_impl.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/mocks.dart';

void main() {
  late AssetHoldingRepositoryImpl repository;
  late MockAssetHoldingRemoteDataSource mockRemote;
  late MockAssetHoldingsDao mockDao;

  const userId = 'user-1';

  // Failure is a plain sealed class (no value equality), so assert the
  // Left branch by type + message rather than by instance equality.
  void expectServerFailure(Either<Failure, Object?> result, String message) {
    result.fold(
      (failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, message);
      },
      (_) => fail('expected Left(ServerFailure)'),
    );
  }

  AssetHoldingEntity buildHolding({
    String id = 'holding-1',
    String uid = userId,
    String accountId = 'acc-1',
    String assetClassId = 'class-1',
    double amount = 1000,
  }) {
    return AssetHoldingEntity(
      id: id,
      userId: uid,
      accountId: accountId,
      assetClassId: assetClassId,
      amount: amount,
      updatedAt: DateTime(2026, 5, 28),
    );
  }

  setUpAll(() {
    // Custom types matched via any()/captureAny() need a fallback registered.
    registerFallbackValue(
      AssetHoldingModel.fromEntity(buildHolding()),
    );
    registerFallbackValue(<AssetHoldingEntity>[]);
  });

  // Builds a repository whose lazy userId resolves to [resolved].
  AssetHoldingRepositoryImpl buildRepository(String resolved) {
    mockRemote = MockAssetHoldingRemoteDataSource();
    mockDao = MockAssetHoldingsDao();
    return AssetHoldingRepositoryImpl(
      remoteDataSource: mockRemote,
      assetHoldingsDao: mockDao,
      resolveUserId: () => resolved,
    );
  }

  setUp(() {
    repository = buildRepository(userId);
  });

  group('getAssetHoldings', () {
    test(
      'forceRefresh deletes all then inserts ONLY when remote non-empty',
      () async {
        final remoteModels = [AssetHoldingModel.fromEntity(buildHolding())];
        final localEntities = [buildHolding()];

        when(
          () => mockRemote.getAssetHoldings(userId: userId),
        ).thenAnswer((_) async => remoteModels);
        when(
          () => mockDao.deleteAllAssetHoldings(),
        ).thenAnswer((_) async {});
        when(
          () => mockDao.insertAllAssetHoldings(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockDao.getAssetHoldings(userId),
        ).thenAnswer((_) async => localEntities);

        final result = await repository.getAssetHoldings(
          userId: userId,
          forceRefresh: true,
        );

        expect(
          result,
          Right<Failure, List<AssetHoldingEntity>>(localEntities),
        );
        verify(() => mockDao.deleteAllAssetHoldings()).called(1);
        verify(() => mockDao.insertAllAssetHoldings(remoteModels)).called(1);
      },
    );

    test(
      'forceRefresh deletes all but does NOT insert when remote empty',
      () async {
        final emptyLocal = <AssetHoldingEntity>[];
        when(
          () => mockRemote.getAssetHoldings(userId: userId),
        ).thenAnswer((_) async => <AssetHoldingModel>[]);
        when(
          () => mockDao.deleteAllAssetHoldings(),
        ).thenAnswer((_) async {});
        when(
          () => mockDao.getAssetHoldings(userId),
        ).thenAnswer((_) async => emptyLocal);

        final result = await repository.getAssetHoldings(
          userId: userId,
          forceRefresh: true,
        );

        expect(
          result,
          Right<Failure, List<AssetHoldingEntity>>(emptyLocal),
        );
        verify(() => mockDao.deleteAllAssetHoldings()).called(1);
        verifyNever(() => mockDao.insertAllAssetHoldings(any()));
      },
    );

    test('reads local cache and skips remote when forceRefresh is false',
        () async {
      final localEntities = [buildHolding()];
      when(
        () => mockDao.getAssetHoldings(userId),
      ).thenAnswer((_) async => localEntities);

      final result = await repository.getAssetHoldings(userId: userId);

      expect(
        result,
        Right<Failure, List<AssetHoldingEntity>>(localEntities),
      );
      verifyNever(
        () => mockRemote.getAssetHoldings(userId: any(named: 'userId')),
      );
      verifyNever(() => mockDao.deleteAllAssetHoldings());
    });

    test('returns ServerFailure when remote throws', () async {
      when(
        () => mockRemote.getAssetHoldings(userId: userId),
      ).thenThrow(const ServerException('boom'));

      final result = await repository.getAssetHoldings(
        userId: userId,
        forceRefresh: true,
      );

      expect(result, isA<Left<Failure, List<AssetHoldingEntity>>>());
      expectServerFailure(result, 'boom');
    });
  });

  group('createAssetHolding', () {
    test('creates remotely, upserts locally and returns Right(result)',
        () async {
      final holding = buildHolding();
      final created = AssetHoldingModel.fromEntity(
        buildHolding(id: 'remote-1'),
      );

      when(
        () => mockRemote.createAssetHolding(any()),
      ).thenAnswer((_) async => created);
      when(() => mockDao.upsertAssetHolding(any())).thenAnswer((_) async {});

      final result = await repository.createAssetHolding(holding);

      expect(result, Right<Failure, AssetHoldingEntity>(created));
      final captured = verify(
        () => mockRemote.createAssetHolding(captureAny()),
      ).captured.single as AssetHoldingModel;
      expect(captured.id, holding.id);
      verify(() => mockDao.upsertAssetHolding(created)).called(1);
    });

    test('returns ServerFailure and skips dao when remote throws', () async {
      when(
        () => mockRemote.createAssetHolding(any()),
      ).thenThrow(const ServerException('create failed'));

      final result = await repository.createAssetHolding(buildHolding());

      expect(result, isA<Left<Failure, AssetHoldingEntity>>());
      expectServerFailure(result, 'create failed');
      verifyNever(() => mockDao.upsertAssetHolding(any()));
    });
  });

  group('updateAssetHolding', () {
    test('updates remotely, upserts locally and returns Right(result)',
        () async {
      final holding = buildHolding(amount: 2000);
      final updated = AssetHoldingModel.fromEntity(holding);

      when(
        () => mockRemote.updateAssetHolding(any()),
      ).thenAnswer((_) async => updated);
      when(() => mockDao.upsertAssetHolding(any())).thenAnswer((_) async {});

      final result = await repository.updateAssetHolding(holding);

      expect(result, Right<Failure, AssetHoldingEntity>(updated));
      verify(() => mockRemote.updateAssetHolding(any())).called(1);
      verify(() => mockDao.upsertAssetHolding(updated)).called(1);
    });

    test('returns ServerFailure and skips dao when remote throws', () async {
      when(
        () => mockRemote.updateAssetHolding(any()),
      ).thenThrow(const ServerException('update failed'));

      final result = await repository.updateAssetHolding(buildHolding());

      expect(result, isA<Left<Failure, AssetHoldingEntity>>());
      expectServerFailure(result, 'update failed');
      verifyNever(() => mockDao.upsertAssetHolding(any()));
    });
  });

  group('deleteAssetHolding', () {
    const holdingId = 'holding-1';

    test('deletes remotely then locally and returns Right(null)', () async {
      when(
        () => mockRemote.deleteAssetHolding(holdingId),
      ).thenAnswer((_) async {});
      when(
        () => mockDao.deleteAssetHolding(holdingId),
      ).thenAnswer((_) async {});

      final result = await repository.deleteAssetHolding(holdingId);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemote.deleteAssetHolding(holdingId)).called(1);
      verify(() => mockDao.deleteAssetHolding(holdingId)).called(1);
    });

    test('returns ServerFailure when remote throws', () async {
      when(
        () => mockRemote.deleteAssetHolding(holdingId),
      ).thenThrow(const ServerException('delete failed'));

      final result = await repository.deleteAssetHolding(holdingId);

      expect(result, isA<Left<Failure, void>>());
      expectServerFailure(result, 'delete failed');
    });
  });

  group('deleteHoldingsForAccount', () {
    const accountId = 'acc-1';

    test('short-circuits when resolveUserId() is empty', () async {
      repository = buildRepository('');

      final result = await repository.deleteHoldingsForAccount(accountId);

      expect(result, const Right<Failure, void>(null));
      verifyNever(
        () => mockRemote.deleteHoldingsForAccount(
          userId: any(named: 'userId'),
          accountId: any(named: 'accountId'),
        ),
      );
      verifyNever(() => mockDao.deleteHoldingsForAccount(any()));
    });

    test('delegates to remote and dao when userId is resolved', () async {
      when(
        () => mockRemote.deleteHoldingsForAccount(
          userId: userId,
          accountId: accountId,
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockDao.deleteHoldingsForAccount(accountId),
      ).thenAnswer((_) async {});

      final result = await repository.deleteHoldingsForAccount(accountId);

      expect(result, const Right<Failure, void>(null));
      verify(
        () => mockRemote.deleteHoldingsForAccount(
          userId: userId,
          accountId: accountId,
        ),
      ).called(1);
      verify(() => mockDao.deleteHoldingsForAccount(accountId)).called(1);
    });

    test('returns ServerFailure when remote throws', () async {
      when(
        () => mockRemote.deleteHoldingsForAccount(
          userId: userId,
          accountId: accountId,
        ),
      ).thenThrow(const ServerException('cascade failed'));

      final result = await repository.deleteHoldingsForAccount(accountId);

      expect(result, isA<Left<Failure, void>>());
      expectServerFailure(result, 'cascade failed');
      verifyNever(() => mockDao.deleteHoldingsForAccount(any()));
    });
  });

  group('deleteHoldingsForClass', () {
    const classId = 'class-1';

    test('short-circuits when resolveUserId() is empty', () async {
      repository = buildRepository('');

      final result = await repository.deleteHoldingsForClass(classId);

      expect(result, const Right<Failure, void>(null));
      verifyNever(
        () => mockRemote.deleteHoldingsForClass(
          userId: any(named: 'userId'),
          classId: any(named: 'classId'),
        ),
      );
      verifyNever(() => mockDao.deleteHoldingsForClass(any()));
    });

    test('delegates to remote and dao when userId is resolved', () async {
      when(
        () => mockRemote.deleteHoldingsForClass(
          userId: userId,
          classId: classId,
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockDao.deleteHoldingsForClass(classId),
      ).thenAnswer((_) async {});

      final result = await repository.deleteHoldingsForClass(classId);

      expect(result, const Right<Failure, void>(null));
      verify(
        () => mockRemote.deleteHoldingsForClass(
          userId: userId,
          classId: classId,
        ),
      ).called(1);
      verify(() => mockDao.deleteHoldingsForClass(classId)).called(1);
    });

    test('returns ServerFailure when remote throws', () async {
      when(
        () => mockRemote.deleteHoldingsForClass(
          userId: userId,
          classId: classId,
        ),
      ).thenThrow(const ServerException('cascade failed'));

      final result = await repository.deleteHoldingsForClass(classId);

      expect(result, isA<Left<Failure, void>>());
      expectServerFailure(result, 'cascade failed');
      verifyNever(() => mockDao.deleteHoldingsForClass(any()));
    });
  });
}
