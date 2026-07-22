import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:financo/features/investing/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(AssetTransactionFactory.buy());
  });

  late MockGetAssetsUseCase getAssets;
  late MockSaveAssetTransactionUseCase saveTransaction;
  late ImportInvestingTransactionsCsvUseCase usecase;

  final aapl = AssetFactory.stockUs(id: 'a-aapl');

  setUp(() {
    getAssets = MockGetAssetsUseCase();
    saveTransaction = MockSaveAssetTransactionUseCase();
    usecase = ImportInvestingTransactionsCsvUseCase(
      getAssets: getAssets,
      saveTransaction: saveTransaction,
    );
  });

  test('preview resolves a known ticker and skips an unknown one', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => Right([aapl]));

    final result = await usecase.preview(
      userId: 'user-1',
      csvContent:
          'ticker,operation,quantity,price,date\n'
          'AAPL,buy,10,150,02/01/2024\n'
          'ZZZZ,buy,5,10,03/01/2024\n',
    );

    final preview = result.getOrElse(() => throw StateError('right'));
    expect(preview.toImport.map((i) => i.ticker), ['AAPL']);
    expect(preview.skipped.single.ticker, 'ZZZZ');
    expect(
      preview.skipped.single.problem,
      InvestingTransactionImportProblem.assetNotFound,
    );
  });

  test('a dividend row carries only its amount', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => Right([aapl]));

    final result = await usecase.preview(
      userId: 'user-1',
      csvContent:
          'ticker,operation,amount,date\nAAPL,dividend,12.50,10/04/2024\n',
    );

    final preview = result.getOrElse(() => throw StateError('right'));
    final item = preview.toImport.single;
    expect(item.kind, TransactionKind.dividend);
    expect(item.amountMajor, 12.5);
    expect(item.quantity, 0);
  });

  test('an asset with no institution is skipped', () async {
    when(() => getAssets(userId: 'user-1')).thenAnswer(
      (_) async => Right([AssetFactory.stockUs(institutionId: null)]),
    );

    final result = await usecase.preview(
      userId: 'user-1',
      csvContent: 'ticker,operation,quantity,price\nAAPL,buy,1,10\n',
    );

    expect(
      result.getOrElse(() => throw StateError('right')).skipped.single.problem,
      InvestingTransactionImportProblem.assetNoInstitution,
    );
  });

  test('an ambiguous ticker (two markets, no market col) is skipped', () async {
    when(() => getAssets(userId: 'user-1')).thenAnswer(
      (_) async => Right([
        AssetFactory.stockUs(id: 'a1', ticker: 'X'),
        AssetFactory.stockUs(id: 'a2', ticker: 'X', market: Market.global),
      ]),
    );

    final result = await usecase.preview(
      userId: 'user-1',
      csvContent: 'ticker,operation,quantity,price\nX,buy,1,10\n',
    );

    expect(
      result.getOrElse(() => throw StateError('right')).skipped.single.problem,
      InvestingTransactionImportProblem.assetAmbiguous,
    );
  });

  test('a friendly market spelling (USA) still resolves the asset', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => Right([aapl])); // aapl.market == Market.us

    final result = await usecase.preview(
      userId: 'user-1',
      csvContent: 'ticker,market,operation,quantity,price\nAAPL,USA,buy,1,10\n',
    );

    final preview = result.getOrElse(() => throw StateError('right'));
    expect(preview.toImport.map((i) => i.ticker), ['AAPL']);
    expect(preview.skipped, isEmpty);
  });

  test('a non-positive buy quantity fails the parse', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => Right([aapl]));

    final result = await usecase.preview(
      userId: 'user-1',
      csvContent: 'ticker,operation,quantity,price\nAAPL,buy,0,10\n',
    );

    expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
  });

  test('a dividend without an amount fails the parse', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => Right([aapl]));

    final result = await usecase.preview(
      userId: 'user-1',
      csvContent: 'ticker,operation,amount\nAAPL,dividend,0\n',
    );

    expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
  });

  test('importItems saves oldest-first, buy before sell', () async {
    final captured = <AssetTransaction>[];
    when(() => saveTransaction(any())).thenAnswer((invocation) async {
      final tx = invocation.positionalArguments.first as AssetTransaction;
      captured.add(tx);
      return Right(tx);
    });

    final buy = InvestingTransactionImportPreviewItem(
      ticker: 'AAPL',
      kind: TransactionKind.buy,
      quantity: 10,
      unitPriceMajor: 100,
      amountMajor: 0,
      feesMajor: 0,
      date: DateTime(2024, 1, 10),
      asset: aapl,
    );
    final sell = InvestingTransactionImportPreviewItem(
      ticker: 'AAPL',
      kind: TransactionKind.sell,
      quantity: 4,
      unitPriceMajor: 150,
      amountMajor: 0,
      feesMajor: 0,
      date: DateTime(2024, 2, 10),
      asset: aapl,
    );

    // Pass sell first to prove the importer reorders it after the buy.
    final result = await usecase.importItems(
      userId: 'user-1',
      items: [sell, buy],
    );

    expect(
      result.getOrElse(() => throw StateError('right')).importedCount,
      2,
    );
    expect(captured.map((t) => t.kind), [
      TransactionKind.buy,
      TransactionKind.sell,
    ]);
  });

  test('importItems stops and reports a save failure (oversell)', () async {
    when(
      () => saveTransaction(any()),
    ).thenAnswer((_) async => const Left(OversellFailure()));

    final result = await usecase.importItems(
      userId: 'user-1',
      items: [
        InvestingTransactionImportPreviewItem(
          ticker: 'AAPL',
          kind: TransactionKind.sell,
          quantity: 4,
          unitPriceMajor: 150,
          amountMajor: 0,
          feesMajor: 0,
          date: DateTime(2024, 2, 10),
          asset: aapl,
        ),
      ],
    );

    expect(result.fold((f) => f, (_) => null), isA<OversellFailure>());
  });
}
