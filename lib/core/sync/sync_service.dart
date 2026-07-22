import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/asset_classes_dao.dart';
import 'package:financo/core/database/daos/budgets_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/institutions_dao.dart';
import 'package:financo/core/database/daos/investment_assets_dao.dart';
import 'package:financo/core/database/daos/investment_snapshots_dao.dart';
import 'package:financo/core/database/daos/investment_transactions_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/investing/data/datasources/asset_remote_datasource.dart';
import 'package:financo/features/investing/data/datasources/asset_transaction_remote_datasource.dart';
import 'package:financo/features/investing/data/datasources/institution_remote_datasource.dart';
import 'package:financo/features/investing/data/datasources/snapshot_remote_datasource.dart';
import 'package:financo/features/investments/data/datasources/asset_class_remote_datasource.dart';
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';

/// Synchronises Firestore data into the local Drift database.
///
/// Called at startup (full sync) and on sign-out (clear). Covers the cash side
/// (accounts/categories/transactions/budgets) and the V2 investing mirrored
/// collections (allocation classes, institutions, assets, asset transactions,
/// snapshots). The device-local market caches (quotes/fx/index) are NOT synced
/// — they repopulate from the network on demand.
class SyncService {
  SyncService({
    required AccountRemoteDataSource accountRemote,
    required TransactionRemoteDataSource transactionRemote,
    required CategoryRemoteDataSource categoryRemote,
    required BudgetRemoteDataSource budgetRemote,
    required AssetClassRemoteDataSource assetClassRemote,
    required InstitutionRemoteDataSource institutionRemote,
    required AssetRemoteDataSource assetRemote,
    required AssetTransactionRemoteDataSource assetTransactionRemote,
    required SnapshotRemoteDataSource snapshotRemote,
    required AccountsDao accountsDao,
    required TransactionsDao transactionsDao,
    required CategoriesDao categoriesDao,
    required BudgetsDao budgetsDao,
    required AssetClassesDao assetClassesDao,
    required InstitutionsDao institutionsDao,
    required InvestmentAssetsDao investmentAssetsDao,
    required InvestmentTransactionsDao investmentTransactionsDao,
    required InvestmentSnapshotsDao investmentSnapshotsDao,
    required UsersDao usersDao,
    required AppDatabase database,
  }) : _accountRemote = accountRemote,
       _transactionRemote = transactionRemote,
       _categoryRemote = categoryRemote,
       _budgetRemote = budgetRemote,
       _assetClassRemote = assetClassRemote,
       _institutionRemote = institutionRemote,
       _assetRemote = assetRemote,
       _assetTransactionRemote = assetTransactionRemote,
       _snapshotRemote = snapshotRemote,
       _accountsDao = accountsDao,
       _transactionsDao = transactionsDao,
       _categoriesDao = categoriesDao,
       _budgetsDao = budgetsDao,
       _assetClassesDao = assetClassesDao,
       _institutionsDao = institutionsDao,
       _investmentAssetsDao = investmentAssetsDao,
       _investmentTransactionsDao = investmentTransactionsDao,
       _investmentSnapshotsDao = investmentSnapshotsDao,
       _usersDao = usersDao,
       _database = database;

  final AccountRemoteDataSource _accountRemote;
  final TransactionRemoteDataSource _transactionRemote;
  final CategoryRemoteDataSource _categoryRemote;
  final BudgetRemoteDataSource _budgetRemote;
  final AssetClassRemoteDataSource _assetClassRemote;
  final InstitutionRemoteDataSource _institutionRemote;
  final AssetRemoteDataSource _assetRemote;
  final AssetTransactionRemoteDataSource _assetTransactionRemote;
  final SnapshotRemoteDataSource _snapshotRemote;
  final AccountsDao _accountsDao;
  final TransactionsDao _transactionsDao;
  final CategoriesDao _categoriesDao;
  final BudgetsDao _budgetsDao;
  final AssetClassesDao _assetClassesDao;
  final InstitutionsDao _institutionsDao;
  final InvestmentAssetsDao _investmentAssetsDao;
  final InvestmentTransactionsDao _investmentTransactionsDao;
  final InvestmentSnapshotsDao _investmentSnapshotsDao;
  final UsersDao _usersDao;
  final AppDatabase _database;

  /// Fetches **all** data from Firestore and persists it locally.
  ///
  /// Any previous local data is replaced so that deletions on the
  /// server are reflected.
  Future<void> fullSync({
    required String userId,
    required UserEntity user,
  }) async {
    // Phase 1 — fetch from Firestore (network, may throw).
    final accounts = await _accountRemote.getAccounts(userId: userId);
    final categories = await _categoryRemote.getCategories(userId: userId);
    final transactions = await _transactionRemote.getTransactions(
      userId: userId,
    );
    final budgets = await _budgetRemote.getBudgets(userId: userId);
    final assetClasses = await _assetClassRemote.getAssetClasses(
      userId: userId,
    );
    final institutions = await _institutionRemote.getInstitutions(
      userId: userId,
    );
    final assets = await _assetRemote.getAssets(userId: userId);
    final assetTransactions = await _assetTransactionRemote.getTransactions(
      userId: userId,
    );
    final snapshots = await _snapshotRemote.getSnapshots(userId: userId);

    // Phase 2 — persist to Drift (local, fast).
    await _database.clearAllTables();
    await _usersDao.upsertUser(user);
    if (accounts.isNotEmpty) {
      await _accountsDao.insertAllAccounts(accounts);
    }
    if (categories.isNotEmpty) {
      await _categoriesDao.insertAllCategories(categories);
    }
    if (transactions.isNotEmpty) {
      await _transactionsDao.insertAllTransactions(transactions);
    }
    if (budgets.isNotEmpty) {
      await _budgetsDao.insertAllBudgets(budgets);
    }
    if (assetClasses.isNotEmpty) {
      await _assetClassesDao.insertAllAssetClasses(assetClasses);
    }
    if (institutions.isNotEmpty) {
      await _institutionsDao.insertAllInstitutions(institutions);
    }
    if (assets.isNotEmpty) {
      await _investmentAssetsDao.insertAllAssets(assets);
    }
    if (assetTransactions.isNotEmpty) {
      await _investmentTransactionsDao.insertAllTransactions(assetTransactions);
    }
    if (snapshots.isNotEmpty) {
      await _investmentSnapshotsDao.insertAllSnapshots(snapshots);
    }
  }

  /// Removes all locally cached data (used on sign-out).
  Future<void> clearLocalData() async {
    await _database.clearAllTables();
  }
}
