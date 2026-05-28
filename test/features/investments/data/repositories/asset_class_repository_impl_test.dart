import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investments/data/models/asset_class_model.dart';
import 'package:financo/features/investments/data/repositories/asset_class_repository_impl.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/helpers.dart';
import '../../../../harness/mocks.dart';

void main() {
  late AssetClassRepositoryImpl repository;
  late MockAssetClassRemoteDataSource mockRemote;
  late MockAssetClassesDao mockDao;

  // Registers AssetClassEntity + AssetClassModel fallbacks for any()/captureAny.
  setUpAll(registerInvestmentFallbackValues);

  setUp(() {
    mockRemote = MockAssetClassRemoteDataSource();
    mockDao = MockAssetClassesDao();
    repository = AssetClassRepositoryImpl(
      remoteDataSource: mockRemote,
      assetClassesDao: mockDao,
    );
  });

  const userId = 'user-1';

  AssetClassEntity buildEntity({
    String id = 'ac-1',
    String name = 'Stocks',
    double targetPercent = 40,
    String? parentId,
  }) {
    return AssetClassEntity(
      id: id,
      userId: userId,
      name: name,
      icon: 100,
      color: 4280391411,
      targetPercent: targetPercent,
      parentId: parentId,
      createdAt: DateTime(2024),
    );
  }

  group('getAssetClasses', () {
    test('returns local cache without touching remote when not forced',
        () async {
      final classes = [buildEntity()];
      when(
        () => mockDao.getAssetClasses(userId),
      ).thenAnswer((_) async => classes);

      final result = await repository.getAssetClasses(userId: userId);

      expect(result, Right<Failure, List<AssetClassEntity>>(classes));
      verify(() => mockDao.getAssetClasses(userId)).called(1);
      verifyNever(
        () => mockRemote.getAssetClasses(userId: any(named: 'userId')),
      );
      verifyNever(() => mockDao.deleteAllAssetClasses());
    });

    test(
      'force refresh fetches remote, clears cache, inserts, then reads local',
      () async {
        final remoteModels = [
          AssetClassModel.fromEntity(buildEntity(id: 'ac-remote')),
        ];
        final localEntities = [buildEntity(id: 'ac-remote')];

        when(
          () => mockRemote.getAssetClasses(userId: userId),
        ).thenAnswer((_) async => remoteModels);
        when(
          () => mockDao.deleteAllAssetClasses(),
        ).thenAnswer((_) async {});
        when(
          () => mockDao.insertAllAssetClasses(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockDao.getAssetClasses(userId),
        ).thenAnswer((_) async => localEntities);

        final result = await repository.getAssetClasses(
          userId: userId,
          forceRefresh: true,
        );

        expect(result, Right<Failure, List<AssetClassEntity>>(localEntities));
        // Cache is cleared before the fresh remote rows are inserted.
        verifyInOrder([
          () => mockRemote.getAssetClasses(userId: userId),
          () => mockDao.deleteAllAssetClasses(),
          () => mockDao.insertAllAssetClasses(remoteModels),
          () => mockDao.getAssetClasses(userId),
        ]);
      },
    );

    test(
      'force refresh with empty remote clears cache but skips insert',
      () async {
        when(
          () => mockRemote.getAssetClasses(userId: userId),
        ).thenAnswer((_) async => <AssetClassModel>[]);
        when(
          () => mockDao.deleteAllAssetClasses(),
        ).thenAnswer((_) async {});
        when(
          () => mockDao.getAssetClasses(userId),
        ).thenAnswer((_) async => <AssetClassEntity>[]);

        final result = await repository.getAssetClasses(
          userId: userId,
          forceRefresh: true,
        );

        expect(result.isRight(), isTrue);
        expect(result.getOrElse(() => [buildEntity()]), isEmpty);
        verify(() => mockDao.deleteAllAssetClasses()).called(1);
        verifyNever(() => mockDao.insertAllAssetClasses(any()));
      },
    );

    test('maps ServerException to Left(ServerFailure)', () async {
      when(
        () => mockRemote.getAssetClasses(userId: userId),
      ).thenThrow(const ServerException('Failed to fetch asset classes.'));

      final result = await repository.getAssetClasses(
        userId: userId,
        forceRefresh: true,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => mockDao.insertAllAssetClasses(any()));
    });
  });

  group('createAssetClass', () {
    test('creates remotely with mapped model and upserts the result',
        () async {
      final entity = buildEntity();
      final created = AssetClassModel.fromEntity(buildEntity(name: 'Created'));

      when(
        () => mockRemote.createAssetClass(any()),
      ).thenAnswer((_) async => created);
      when(() => mockDao.upsertAssetClass(any())).thenAnswer((_) async {});

      final result = await repository.createAssetClass(entity);

      expect(result, Right<Failure, AssetClassEntity>(created));
      // Entity is converted to its model before reaching the datasource.
      final captured = verify(
        () => mockRemote.createAssetClass(captureAny()),
      ).captured.single as AssetClassModel;
      expect(captured.id, entity.id);
      expect(captured.name, entity.name);
      // The remote-returned row (not the input) is what gets cached.
      verify(() => mockDao.upsertAssetClass(created)).called(1);
    });

    test('maps ServerException to Left(ServerFailure) and skips cache',
        () async {
      when(
        () => mockRemote.createAssetClass(any()),
      ).thenThrow(const ServerException('Failed to create asset class.'));

      final result = await repository.createAssetClass(buildEntity());

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => mockDao.upsertAssetClass(any()));
    });
  });

  group('updateAssetClass', () {
    test('updates remotely with mapped model and upserts the result',
        () async {
      final entity = buildEntity(name: 'Updated', targetPercent: 55);
      final updated = AssetClassModel.fromEntity(entity);

      when(
        () => mockRemote.updateAssetClass(any()),
      ).thenAnswer((_) async => updated);
      when(() => mockDao.upsertAssetClass(any())).thenAnswer((_) async {});

      final result = await repository.updateAssetClass(entity);

      expect(result, Right<Failure, AssetClassEntity>(updated));
      final captured = verify(
        () => mockRemote.updateAssetClass(captureAny()),
      ).captured.single as AssetClassModel;
      expect(captured.id, entity.id);
      expect(captured.targetPercent, 55);
      verify(() => mockDao.upsertAssetClass(updated)).called(1);
    });

    test('maps ServerException to Left(ServerFailure) and skips cache',
        () async {
      when(
        () => mockRemote.updateAssetClass(any()),
      ).thenThrow(const ServerException('Failed to update asset class.'));

      final result = await repository.updateAssetClass(buildEntity());

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => mockDao.upsertAssetClass(any()));
    });
  });

  group('deleteAssetClass', () {
    const id = 'ac-1';

    test('deletes remotely then locally for the same id', () async {
      when(() => mockRemote.deleteAssetClass(any())).thenAnswer((_) async {});
      when(() => mockDao.deleteAssetClass(any())).thenAnswer((_) async {});

      final result = await repository.deleteAssetClass(id);

      expect(result, const Right<Failure, void>(null));
      verifyInOrder([
        () => mockRemote.deleteAssetClass(id),
        () => mockDao.deleteAssetClass(id),
      ]);
    });

    test('maps ServerException to Left(ServerFailure) and skips local delete',
        () async {
      when(
        () => mockRemote.deleteAssetClass(any()),
      ).thenThrow(const ServerException('Failed to delete asset class.'));

      final result = await repository.deleteAssetClass(id);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => mockDao.deleteAssetClass(any()));
    });
  });
}
