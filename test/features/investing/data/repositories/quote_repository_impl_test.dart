import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/repositories/quote_repository_impl.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/quote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/investing_factories.dart';
import '../../../../harness/mocks.dart';

class _FakeSource implements QuoteDataSource {
  _FakeSource(this._result);

  final Either<Failure, List<Quote>> _result;

  @override
  bool supports(Asset asset) => true;

  @override
  Future<Either<Failure, List<Quote>>> fetch(List<Asset> assets) async =>
      _result;
}

void main() {
  setUpAll(() => registerFallbackValue(<Quote>[]));

  late MockQuotesDao dao;
  setUp(() => dao = MockQuotesDao());

  Quote quote(String id) => Quote(
    assetId: id,
    unitPrice: Money.fromMajor(10, Currency.brl),
    asOf: DateTime(2024),
    fetchedAt: DateTime(2024),
    source: QuoteSource.brapi,
  );

  test('getCached with no ids returns an empty list', () async {
    final repo = QuoteRepositoryImpl(quotesDao: dao, sources: const []);
    final r = await repo.getCached([]);
    expect(r.getOrElse(() => []), isEmpty);
  });

  test('getCached returns the cached quotes from the dao', () async {
    when(
      () => dao.getQuotesByAssetIds(['a1']),
    ).thenAnswer((_) async => [quote('a1')]);
    final repo = QuoteRepositoryImpl(quotesDao: dao, sources: const []);

    final r = await repo.getCached(['a1']);
    expect(r.getOrElse(() => []), hasLength(1));
  });

  test('refresh routes to the sources and caches the result', () async {
    when(() => dao.upsertQuotes(any())).thenAnswer((_) async {});
    final repo = QuoteRepositoryImpl(
      quotesDao: dao,
      sources: [
        _FakeSource(Right([quote('a1')])),
      ],
    );

    final r = await repo.refresh([AssetFactory.stockBr()]);

    expect(r.getOrElse(() => []), hasLength(1));
    verify(() => dao.upsertQuotes(any())).called(1);
  });

  test('refresh returns a failure when every source fails', () async {
    final repo = QuoteRepositoryImpl(
      quotesDao: dao,
      sources: [_FakeSource(const Left(ServerFailure()))],
    );

    final r = await repo.refresh([AssetFactory.stockBr()]);
    expect(r.isLeft(), isTrue);
  });

  test('lastFetchedAt delegates to the dao', () async {
    when(
      () => dao.newestFetchedAt(['a1']),
    ).thenAnswer((_) async => DateTime(2024, 6));
    final repo = QuoteRepositoryImpl(quotesDao: dao, sources: const []);

    expect(await repo.lastFetchedAt(['a1']), DateTime(2024, 6));
  });
}
