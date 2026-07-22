import 'package:financo/features/investing/data/datasources/awesomeapi_fx_data_source.dart';
import 'package:financo/features/investing/data/datasources/bcb_sgs_index_data_source.dart';
import 'package:financo/features/investing/data/datasources/caching_fx_data_source.dart';
import 'package:financo/features/investing/data/datasources/caching_index_data_source.dart';
import 'package:financo/features/investing/data/datasources/coingecko_quote_data_source.dart';
import 'package:financo/features/investing/data/datasources/tesouro_direto_data_source.dart';
import 'package:financo/features/investing/data/repositories/quote_repository_impl.dart';
import 'package:financo/features/investing/domain/datasources/index_data_source.dart';
import 'package:financo/features/investing/domain/datasources/quote_data_source.dart';
import 'package:financo/features/investing/domain/repositories/quote_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

/// Registers the market-data layer (F2b): the shared HTTP client, the keyless
/// quote/FX/index adapters (client-side, no API key), their in-memory caching
/// wrappers, and the cache-first [QuoteRepository]. Keyed sources (brapi /
/// Finnhub, via a Cloud Functions proxy) are added in F2b-2b.
void registerMarketDataDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<FxDataSource>(
      () => CachingFxDataSource(AwesomeApiFxDataSource(sl<http.Client>())),
    )
    ..registerLazySingleton<IndexDataSource>(
      () => CachingIndexDataSource(BcbSgsIndexDataSource(sl<http.Client>())),
    )
    ..registerLazySingleton<QuoteRepository>(
      () => QuoteRepositoryImpl(
        quotesDao: sl(),
        sources: [
          CoinGeckoQuoteDataSource(sl<http.Client>()),
          TesouroDiretoDataSource(sl<http.Client>()),
        ],
      ),
    );
}
