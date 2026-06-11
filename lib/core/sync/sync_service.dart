import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/budgets_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/features/accounts/data/datasources/account_remote_datasource.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:financo/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:financo/features/transactions/data/datasources/transaction_remote_datasource.dart';

/// Synchronises Firestore data into the local Drift database.
///
/// Called at startup (full sync) and on sign-out (clear).
class SyncService {
  SyncService({
    required AccountRemoteDataSource accountRemote,
    required TransactionRemoteDataSource transactionRemote,
    required CategoryRemoteDataSource categoryRemote,
    required BudgetRemoteDataSource budgetRemote,
    required AccountsDao accountsDao,
    required TransactionsDao transactionsDao,
    required CategoriesDao categoriesDao,
    required BudgetsDao budgetsDao,
    required UsersDao usersDao,
    required AppDatabase database,
  }) : _accountRemote = accountRemote,
       _transactionRemote = transactionRemote,
       _categoryRemote = categoryRemote,
       _budgetRemote = budgetRemote,
       _accountsDao = accountsDao,
       _transactionsDao = transactionsDao,
       _categoriesDao = categoriesDao,
       _budgetsDao = budgetsDao,
       _usersDao = usersDao,
       _database = database;

  final AccountRemoteDataSource _accountRemote;
  final TransactionRemoteDataSource _transactionRemote;
  final CategoryRemoteDataSource _categoryRemote;
  final BudgetRemoteDataSource _budgetRemote;
  final AccountsDao _accountsDao;
  final TransactionsDao _transactionsDao;
  final CategoriesDao _categoriesDao;
  final BudgetsDao _budgetsDao;
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
    final accounts = await _accountRemote.getAccounts(
      userId: userId,
    );
    final categories = await _categoryRemote.getCategories(
      userId: userId,
    );
    final transactions = await _transactionRemote.getTransactions(
      userId: userId,
    );
    final budgets = await _budgetRemote.getBudgets(userId: userId);

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
  }

  /// Removes all locally cached data (used on sign-out).
  Future<void> clearLocalData() async {
    await _database.clearAllTables();
  }
}
