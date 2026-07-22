import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/usecases/create_asset_usecase.dart';
import 'package:financo/features/investing/domain/usecases/delete_asset_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(AssetFactory.stockUs());
  });

  late MockAssetRepository assets;
  late MockAssetTransactionRepository transactions;

  setUp(() {
    assets = MockAssetRepository();
    transactions = MockAssetTransactionRepository();
  });

  group('CreateAssetUseCase', () {
    late CreateAssetUseCase useCase;
    setUp(() => useCase = CreateAssetUseCase(assets));

    test('rejects a blank ticker', () async {
      final result = await useCase(AssetFactory.stockUs(ticker: '  '));
      result.leftMap((f) => expect(f, isA<EmptyNameFailure>()));
      expect(result.isLeft(), isTrue);
    });

    test('rejects a missing institution', () async {
      final result = await useCase(AssetFactory.stockUs(institutionId: null));
      result.leftMap((f) => expect(f, isA<AssetInstitutionRequiredFailure>()));
      expect(result.isLeft(), isTrue);
    });

    test('rejects a duplicate (ticker, market)', () async {
      when(() => assets.getAssets(userId: 'user-1')).thenAnswer(
        (_) async => Right([AssetFactory.stockUs()]),
      );
      final result = await useCase(
        AssetFactory.stockUs(id: 'other', ticker: 'aapl'),
      );
      result.leftMap((f) => expect(f, isA<DuplicateAssetFailure>()));
      expect(result.isLeft(), isTrue);
    });

    test('creates and uppercases the ticker', () async {
      when(
        () => assets.getAssets(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([]));
      when(() => assets.createAsset(any())).thenAnswer(
        (invocation) async =>
            Right(invocation.positionalArguments.first as Asset),
      );

      final result = await useCase(AssetFactory.stockUs(ticker: 'aapl'));
      expect(result.isRight(), isTrue);
      final captured =
          verify(() => assets.createAsset(captureAny())).captured.single
              as Asset;
      expect(captured.ticker, 'AAPL');
    });
  });

  group('DeleteAssetUseCase', () {
    late DeleteAssetUseCase useCase;
    setUp(
      () => useCase = DeleteAssetUseCase(
        assetRepository: assets,
        transactionRepository: transactions,
      ),
    );

    test('blocks deletion when a transaction references it', () async {
      when(() => transactions.getTransactions(userId: 'user-1')).thenAnswer(
        (_) async =>
            Right([AssetTransactionFactory.buy()]),
      );
      final result = await useCase(AssetFactory.stockUs());
      result.leftMap((f) => expect(f, isA<AssetInUseFailure>()));
      expect(result.isLeft(), isTrue);
      verifyNever(() => assets.deleteAsset(any()));
    });

    test('deletes when no transactions reference it', () async {
      when(
        () => transactions.getTransactions(userId: 'user-1'),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => assets.deleteAsset('asset-aapl'),
      ).thenAnswer((_) async => const Right(null));
      final result = await useCase(AssetFactory.stockUs());
      expect(result.isRight(), isTrue);
    });
  });
}
