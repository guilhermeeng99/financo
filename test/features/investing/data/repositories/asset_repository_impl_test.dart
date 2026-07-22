import 'package:financo/features/investing/data/models/asset_model.dart';
import 'package:financo/features/investing/data/repositories/asset_repository_impl.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(AssetModel.fromEntity(AssetFactory.stockUs()));
    registerFallbackValue(AssetFactory.stockUs());
    registerFallbackValue(<Asset>[]);
  });

  late MockAssetRemoteDataSource remote;
  late MockInvestmentAssetsDao dao;
  late AssetRepositoryImpl repo;

  setUp(() {
    remote = MockAssetRemoteDataSource();
    dao = MockInvestmentAssetsDao();
    repo = AssetRepositoryImpl(remoteDataSource: remote, assetsDao: dao);
  });

  test('getAssets with forceRefresh pulls remote and replaces cache', () async {
    when(() => remote.getAssets(userId: 'user-1')).thenAnswer(
      (_) async => [AssetModel.fromEntity(AssetFactory.stockUs())],
    );
    when(() => dao.deleteAllAssets()).thenAnswer((_) async {});
    when(() => dao.insertAllAssets(any())).thenAnswer((_) async {});
    when(
      () => dao.getAssets('user-1'),
    ).thenAnswer((_) async => [AssetFactory.stockUs()]);

    final result = await repo.getAssets(userId: 'user-1', forceRefresh: true);

    expect(result.isRight(), isTrue);
    verify(() => dao.deleteAllAssets()).called(1);
    verify(() => dao.insertAllAssets(any())).called(1);
  });

  test('createAsset writes remote then upserts the cache', () async {
    final created = AssetModel.fromEntity(AssetFactory.stockUs());
    when(() => remote.createAsset(any())).thenAnswer((_) async => created);
    when(() => dao.upsertAsset(any())).thenAnswer((_) async {});

    final result = await repo.createAsset(AssetFactory.stockUs());

    expect(result.isRight(), isTrue);
    verify(() => dao.upsertAsset(created)).called(1);
  });

  test('deleteAsset deletes remote then local', () async {
    when(() => remote.deleteAsset('asset-aapl')).thenAnswer((_) async {});
    when(() => dao.deleteAsset('asset-aapl')).thenAnswer((_) async {});

    final result = await repo.deleteAsset('asset-aapl');

    expect(result.isRight(), isTrue);
    verify(() => remote.deleteAsset('asset-aapl')).called(1);
    verify(() => dao.deleteAsset('asset-aapl')).called(1);
  });
}
