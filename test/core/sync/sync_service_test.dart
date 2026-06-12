import 'package:financo/core/sync/sync_service.dart';
import 'package:financo/features/accounts/data/models/account_model.dart';
import 'package:financo/features/budgets/data/models/budget_model.dart';
import 'package:financo/features/categories/data/models/category_model.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../harness/factories/account_factory.dart';
import '../../harness/factories/budget_factory.dart';
import '../../harness/factories/category_factory.dart';
import '../../harness/factories/transaction_factory.dart';
import '../../harness/factories/user_factory.dart';
import '../../harness/helpers.dart';
import '../../harness/mocks.dart';

void main() {
  late MockAccountRemoteDataSource accountRemote;
  late MockTransactionRemoteDataSource transactionRemote;
  late MockCategoryRemoteDataSource categoryRemote;
  late MockBudgetRemoteDataSource budgetRemote;
  late MockAccountsDao accountsDao;
  late MockTransactionsDao transactionsDao;
  late MockCategoriesDao categoriesDao;
  late MockBudgetsDao budgetsDao;
  late MockUsersDao usersDao;
  late MockAppDatabase database;
  late SyncService service;

  const userId = 'user-1';
  final user = UserFactory.entity();

  final accounts = [AccountModel.fromEntity(AccountFactory.checking())];
  final categories = [CategoryModel.fromEntity(CategoryFactory.expense())];
  final transactions = [
    TransactionModel.fromEntity(TransactionFactory.expense()),
  ];
  final budgets = [BudgetModel.fromEntity(BudgetFactory.make())];

  setUpAll(() {
    registerAuthFallbackValues();
    registerAccountFallbackValues();
    registerCategoryFallbackValues();
    registerTransactionFallbackValues();
    registerBudgetFallbackValues();
  });

  setUp(() {
    accountRemote = MockAccountRemoteDataSource();
    transactionRemote = MockTransactionRemoteDataSource();
    categoryRemote = MockCategoryRemoteDataSource();
    budgetRemote = MockBudgetRemoteDataSource();
    accountsDao = MockAccountsDao();
    transactionsDao = MockTransactionsDao();
    categoriesDao = MockCategoriesDao();
    budgetsDao = MockBudgetsDao();
    usersDao = MockUsersDao();
    database = MockAppDatabase();
    service = SyncService(
      accountRemote: accountRemote,
      transactionRemote: transactionRemote,
      categoryRemote: categoryRemote,
      budgetRemote: budgetRemote,
      accountsDao: accountsDao,
      transactionsDao: transactionsDao,
      categoriesDao: categoriesDao,
      budgetsDao: budgetsDao,
      usersDao: usersDao,
      database: database,
    );

    when(() => database.clearAllTables()).thenAnswer((_) async {});
    when(() => usersDao.upsertUser(any())).thenAnswer((_) async {});
    when(() => accountsDao.insertAllAccounts(any())).thenAnswer((_) async {});
    when(() => categoriesDao.insertAllCategories(any()))
        .thenAnswer((_) async {});
    when(() => transactionsDao.insertAllTransactions(any()))
        .thenAnswer((_) async {});
    when(() => budgetsDao.insertAllBudgets(any())).thenAnswer((_) async {});
  });

  void stubRemotes({
    List<AccountModel>? accountList,
    List<CategoryModel>? categoryList,
    List<TransactionModel>? transactionList,
    List<BudgetModel>? budgetList,
  }) {
    when(() => accountRemote.getAccounts(userId: userId))
        .thenAnswer((_) async => accountList ?? accounts);
    when(() => categoryRemote.getCategories(userId: userId))
        .thenAnswer((_) async => categoryList ?? categories);
    when(() => transactionRemote.getTransactions(userId: userId))
        .thenAnswer((_) async => transactionList ?? transactions);
    when(() => budgetRemote.getBudgets(userId: userId))
        .thenAnswer((_) async => budgetList ?? budgets);
  }

  group('fullSync', () {
    test('clears local tables before persisting the fetched data', () async {
      stubRemotes();

      await service.fullSync(userId: userId, user: user);

      verifyInOrder([
        () => database.clearAllTables(),
        () => usersDao.upsertUser(user),
        () => accountsDao.insertAllAccounts(accounts),
        () => categoriesDao.insertAllCategories(categories),
        () => transactionsDao.insertAllTransactions(transactions),
        () => budgetsDao.insertAllBudgets(budgets),
      ]);
    });

    test('skips empty collections so Drift batches stay no-op free',
        () async {
      stubRemotes(
        accountList: const [],
        categoryList: const [],
        transactionList: const [],
        budgetList: const [],
      );

      await service.fullSync(userId: userId, user: user);

      verify(() => database.clearAllTables()).called(1);
      verify(() => usersDao.upsertUser(user)).called(1);
      verifyNever(() => accountsDao.insertAllAccounts(any()));
      verifyNever(() => categoriesDao.insertAllCategories(any()));
      verifyNever(() => transactionsDao.insertAllTransactions(any()));
      verifyNever(() => budgetsDao.insertAllBudgets(any()));
    });

    test('a fetch failure leaves the local cache untouched', () async {
      // Phase ordering matters: every remote read happens before the first
      // local write, so a network blow-up cannot wipe usable cached data.
      when(() => accountRemote.getAccounts(userId: userId))
          .thenThrow(Exception('network down'));
      when(() => categoryRemote.getCategories(userId: userId))
          .thenAnswer((_) async => categories);
      when(() => transactionRemote.getTransactions(userId: userId))
          .thenAnswer((_) async => transactions);
      when(() => budgetRemote.getBudgets(userId: userId))
          .thenAnswer((_) async => budgets);

      await expectLater(
        service.fullSync(userId: userId, user: user),
        throwsException,
      );

      verifyNever(() => database.clearAllTables());
      verifyNever(() => usersDao.upsertUser(any()));
      verifyNever(() => accountsDao.insertAllAccounts(any()));
    });

    test('a late fetch failure (budgets) still precedes any write', () async {
      stubRemotes();
      when(() => budgetRemote.getBudgets(userId: userId))
          .thenThrow(Exception('budgets fetch failed'));

      await expectLater(
        service.fullSync(userId: userId, user: user),
        throwsException,
      );

      verifyNever(() => database.clearAllTables());
      verifyNever(() => transactionsDao.insertAllTransactions(any()));
    });
  });

  group('clearLocalData', () {
    test('drops every local table and nothing else', () async {
      await service.clearLocalData();

      verify(() => database.clearAllTables()).called(1);
      verifyNever(() => usersDao.upsertUser(any()));
      verifyNever(() => accountsDao.insertAllAccounts(any()));
    });
  });
}
