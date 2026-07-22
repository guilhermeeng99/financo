import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/usecases/import_assets_csv_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(AssetFactory.stockUs());
    registerFallbackValue(InstitutionFactory.nubank());
  });

  late MockGetAssetsUseCase getAssets;
  late MockGetInstitutionsUseCase getInstitutions;
  late MockCreateAssetUseCase createAsset;
  late MockCreateInstitutionUseCase createInstitution;
  late ImportAssetsCsvUseCase usecase;

  setUp(() {
    getAssets = MockGetAssetsUseCase();
    getInstitutions = MockGetInstitutionsUseCase();
    createAsset = MockCreateAssetUseCase();
    createInstitution = MockCreateInstitutionUseCase();
    usecase = ImportAssetsCsvUseCase(
      getAssets: getAssets,
      getInstitutions: getInstitutions,
      createAsset: createAsset,
      createInstitution: createInstitution,
    );
  });

  const csv =
      'ticker,name,kind,market,currency,institution\n'
      'AAPL,Apple,etfUs,us,usd,Avenue\n'
      'PETR4,Petrobras,stockBr,br,brl,Nubank\n';

  test('preview parses rows and applies kind defaults', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => const Right([]));

    final result = await usecase.preview(csvContent: csv, userId: 'user-1');

    final preview = result.getOrElse(
      () => throw StateError('expected right'),
    );
    expect(preview.toCreate, hasLength(2));
    expect(preview.duplicates, isEmpty);
    final aapl = preview.toCreate.first;
    expect(aapl.ticker, 'AAPL');
    expect(aapl.kind, AssetKind.etfUs);
    expect(aapl.market, Market.us);
    expect(aapl.currency, Currency.usd);
    expect(aapl.institutionName, 'Avenue');
  });

  test('preview flags an existing (ticker, market) as a duplicate', () async {
    when(() => getAssets(userId: 'user-1')).thenAnswer(
      (_) async => Right([AssetFactory.stockUs()]),
    );

    final result = await usecase.preview(csvContent: csv, userId: 'user-1');

    final preview = result.getOrElse(
      () => throw StateError('expected right'),
    );
    expect(preview.duplicates.map((i) => i.ticker), ['AAPL']);
    expect(preview.toCreate.map((i) => i.ticker), ['PETR4']);
  });

  test('market and currency default from the kind when omitted', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => const Right([]));

    final result = await usecase.preview(
      csvContent: 'ticker,kind,institution\nBTC,crypto,Binance\n',
      userId: 'user-1',
    );

    final item = result
        .getOrElse(() => throw StateError('right'))
        .toCreate
        .single;
    expect(item.market, Market.global);
    expect(item.currency, Currency.usd);
    expect(item.name, 'BTC'); // name defaults to ticker
  });

  test('importItems creates a missing institution then the asset', () async {
    when(
      () => getInstitutions(userId: 'user-1'),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => createInstitution(any()),
    ).thenAnswer((_) async => Right(InstitutionFactory.avenue()));
    when(
      () => createAsset(any()),
    ).thenAnswer((_) async => Right(AssetFactory.stockUs()));

    final result = await usecase.importItems(
      userId: 'user-1',
      items: const [
        AssetImportPreviewItem(
          ticker: 'AAPL',
          name: 'Apple',
          kind: AssetKind.etfUs,
          market: Market.us,
          currency: Currency.usd,
          institutionName: 'Avenue',
        ),
      ],
    );

    final report = result.getOrElse(
      () => throw StateError('expected right'),
    );
    expect(report.importedCount, 1);
    expect(report.institutionsCreated, 1);
    verify(() => createInstitution(any())).called(1);
    verify(() => createAsset(any())).called(1);
  });

  test('importItems reuses an existing institution by name', () async {
    when(() => getInstitutions(userId: 'user-1')).thenAnswer(
      (_) async => Right([InstitutionFactory.avenue()]),
    );
    when(
      () => createAsset(any()),
    ).thenAnswer((_) async => Right(AssetFactory.stockUs()));

    final result = await usecase.importItems(
      userId: 'user-1',
      items: const [
        AssetImportPreviewItem(
          ticker: 'AAPL',
          name: 'Apple',
          kind: AssetKind.etfUs,
          market: Market.us,
          currency: Currency.usd,
          institutionName: 'Avenue',
        ),
      ],
    );

    final report = result.getOrElse(
      () => throw StateError('expected right'),
    );
    expect(report.institutionsCreated, 0);
    verifyNever(() => createInstitution(any()));
  });

  test('an unknown kind fails the whole parse', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => const Right([]));

    final result = await usecase.preview(
      csvContent: 'ticker,kind,institution\nAAPL,bogus,Avenue\n',
      userId: 'user-1',
    );

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((f) => f, (_) => null),
      isA<ValidationFailure>(),
    );
  });

  test('a missing required column is a validation failure', () async {
    final result = await usecase.preview(
      csvContent: 'ticker,kind\nAAPL,etfUs\n',
      userId: 'user-1',
    );

    expect(result.fold((f) => f, (_) => null), isA<ValidationFailure>());
  });

  test('duplicate (ticker, market) rows within the file collapse', () async {
    when(
      () => getAssets(userId: 'user-1'),
    ).thenAnswer((_) async => const Right([]));

    final result = await usecase.preview(
      csvContent:
          'ticker,kind,institution\nAAPL,etfUs,Avenue\nAAPL,etfUs,Avenue\n',
      userId: 'user-1',
    );

    expect(
      result.getOrElse(() => throw StateError('right')).toCreate,
      hasLength(1),
    );
  });
}
