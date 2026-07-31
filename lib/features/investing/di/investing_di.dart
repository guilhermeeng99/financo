import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/fx_rates_dao.dart';
import 'package:financo/core/database/daos/index_points_dao.dart';
import 'package:financo/core/database/daos/institutions_dao.dart';
import 'package:financo/core/database/daos/investment_assets_dao.dart';
import 'package:financo/core/database/daos/investment_snapshots_dao.dart';
import 'package:financo/core/database/daos/investment_transactions_dao.dart';
import 'package:financo/core/database/daos/quotes_dao.dart';
import 'package:financo/features/investing/data/datasources/asset_remote_datasource.dart';
import 'package:financo/features/investing/data/datasources/asset_transaction_remote_datasource.dart';
import 'package:financo/features/investing/data/datasources/institution_remote_datasource.dart';
import 'package:financo/features/investing/data/datasources/snapshot_remote_datasource.dart';
import 'package:financo/features/investing/data/repositories/asset_repository_impl.dart';
import 'package:financo/features/investing/data/repositories/asset_transaction_repository_impl.dart';
import 'package:financo/features/investing/data/repositories/institution_repository_impl.dart';
import 'package:financo/features/investing/data/repositories/market_cache_store_impl.dart';
import 'package:financo/features/investing/data/repositories/snapshot_repository_impl.dart';
import 'package:financo/features/investing/di/market_data_di.dart';
import 'package:financo/features/investing/domain/repositories/asset_repository.dart';
import 'package:financo/features/investing/domain/repositories/asset_transaction_repository.dart';
import 'package:financo/features/investing/domain/repositories/institution_repository.dart';
import 'package:financo/features/investing/domain/repositories/snapshot_repository.dart';
import 'package:financo/features/investing/domain/services/allocation_service.dart';
import 'package:financo/features/investing/domain/services/institution_valuation_reader.dart';
import 'package:financo/features/investing/domain/services/market_cache_store.dart';
import 'package:financo/features/investing/domain/usecases/create_asset_usecase.dart';
import 'package:financo/features/investing/domain/usecases/create_institution_usecase.dart';
import 'package:financo/features/investing/domain/usecases/delete_asset_transaction_usecase.dart';
import 'package:financo/features/investing/domain/usecases/delete_asset_usecase.dart';
import 'package:financo/features/investing/domain/usecases/delete_institution_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_asset_transactions_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/domain/usecases/get_institutions_usecase.dart';
import 'package:financo/features/investing/domain/usecases/import_assets_csv_usecase.dart';
import 'package:financo/features/investing/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/investing/domain/usecases/record_daily_snapshot_usecase.dart';
import 'package:financo/features/investing/domain/usecases/save_asset_transaction_usecase.dart';
import 'package:financo/features/investing/domain/usecases/sync_investment_cash_flow_usecase.dart';
import 'package:financo/features/investing/domain/usecases/update_asset_usecase.dart';
import 'package:financo/features/investing/domain/usecases/update_institution_usecase.dart';
import 'package:get_it/get_it.dart';

/// Registers the V2 investing module's DAOs, datasources, repositories and use
/// cases. Kept out of the main `injection_container.dart` so the large feature
/// stays self-contained. Called from `initDependencies`.
///
/// Registrations are lazy, so ordering versus the core container does not
/// matter — each dependency resolves on first use.
void registerInvestingDependencies(GetIt sl) {
  sl
    // ─── DAOs ───────────────────────────────────────────────
    ..registerLazySingleton(() => InstitutionsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => InvestmentAssetsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => InvestmentTransactionsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => InvestmentSnapshotsDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => QuotesDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => FxRatesDao(sl<AppDatabase>()))
    ..registerLazySingleton(() => IndexPointsDao(sl<AppDatabase>()))
    // ─── Datasources ────────────────────────────────────────
    ..registerLazySingleton<InstitutionRemoteDataSource>(
      () => InstitutionRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<AssetRemoteDataSource>(
      () => AssetRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<AssetTransactionRemoteDataSource>(
      () => AssetTransactionRemoteDataSourceImpl(firestore: sl()),
    )
    ..registerLazySingleton<SnapshotRemoteDataSource>(
      () => SnapshotRemoteDataSourceImpl(firestore: sl()),
    )
    // ─── Repositories ───────────────────────────────────────
    ..registerLazySingleton<InstitutionRepository>(
      () => InstitutionRepositoryImpl(
        remoteDataSource: sl(),
        institutionsDao: sl(),
      ),
    )
    ..registerLazySingleton<AssetRepository>(
      () => AssetRepositoryImpl(remoteDataSource: sl(), assetsDao: sl()),
    )
    ..registerLazySingleton<AssetTransactionRepository>(
      () => AssetTransactionRepositoryImpl(
        remoteDataSource: sl(),
        transactionsDao: sl(),
      ),
    )
    ..registerLazySingleton<SnapshotRepository>(
      () => SnapshotRepositoryImpl(remoteDataSource: sl(), snapshotsDao: sl()),
    )
    // ─── Market data (F2b) ──────────────────────────────────
    ..registerLazySingleton<MarketCacheStore>(
      () => DriftMarketCacheStore(fxRatesDao: sl(), indexPointsDao: sl()),
    )
    // ─── Use cases ──────────────────────────────────────────
    ..registerLazySingleton(() => GetInstitutionsUseCase(sl()))
    ..registerLazySingleton(() => CreateInstitutionUseCase(sl()))
    ..registerLazySingleton(() => UpdateInstitutionUseCase(sl()))
    ..registerLazySingleton(
      () => DeleteInstitutionUseCase(
        institutionRepository: sl(),
        assetRepository: sl(),
        transactionRepository: sl(),
      ),
    )
    ..registerLazySingleton(() => GetAssetsUseCase(sl()))
    ..registerLazySingleton(() => CreateAssetUseCase(sl()))
    ..registerLazySingleton(() => UpdateAssetUseCase(sl()))
    ..registerLazySingleton(
      () => DeleteAssetUseCase(
        assetRepository: sl(),
        transactionRepository: sl(),
      ),
    )
    ..registerLazySingleton(() => GetAssetTransactionsUseCase(sl()))
    // F8.4: the checking-side cash row of a funded buy/sell. Save and delete
    // both go through it so the aporte/resgate can never drift from its
    // investing leg.
    ..registerLazySingleton(() => SyncInvestmentCashFlowUseCase(sl()))
    ..registerLazySingleton(
      () => SaveAssetTransactionUseCase(
        transactionRepository: sl(),
        assetRepository: sl(),
        syncCashFlow: sl(),
      ),
    )
    ..registerLazySingleton(() => DeleteAssetTransactionUseCase(sl(), sl()))
    ..registerLazySingleton(() => RecordDailySnapshotUseCase(sl()))
    // ─── Allocation (F5) ────────────────────────────────────
    ..registerLazySingleton(AllocationService.new)
    // ─── Institution valuation reader (F8.2) ────────────────
    // Read-only bridge the Dashboard uses to show an investment account's
    // live market value; prices from cache via a fresh pricing engine.
    ..registerLazySingleton(
      () => InstitutionValuationReader(
        transactionRepository: sl(),
        assetRepository: sl(),
        pricingEngine: sl(),
      ),
    )
    // ─── CSV import (F6) ────────────────────────────────────
    ..registerLazySingleton(
      () => ImportAssetsCsvUseCase(
        getAssets: sl(),
        getInstitutions: sl(),
        createAsset: sl(),
        createInstitution: sl(),
      ),
    )
    ..registerLazySingleton(
      () => ImportInvestingTransactionsCsvUseCase(
        getAssets: sl(),
        saveTransaction: sl(),
      ),
    );

  // Market-data layer (adapters, caching, QuoteRepository) — F2b.
  registerMarketDataDependencies(sl);
}
