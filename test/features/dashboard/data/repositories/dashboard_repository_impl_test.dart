import 'package:dartz/dartz.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../harness/factories/transaction_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockTransactionRepository mockTransactionRepo;
  late MockAccountRepository mockAccountRepo;
  late MockCategoryRepository mockCategoryRepo;
  late DashboardRepositoryImpl repository;

  const userId = 'user-1';
  final month = DateTime(2024, 3);

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    mockCategoryRepo = MockCategoryRepository();
    repository = DashboardRepositoryImpl(
      transactionRepository: mockTransactionRepo,
      accountRepository: mockAccountRepo,
      categoryRepository: mockCategoryRepo,
    );
  });

  void stubAccounts(List<AccountEntity> accounts) {
    when(
      () => mockAccountRepo.getAccounts(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<AccountEntity>>(accounts),
    );
  }

  void stubTransactions(List<TransactionEntity> transactions) {
    when(
      () => mockTransactionRepo.getTransactions(
        userId: any(named: 'userId'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        categoryId: any(named: 'categoryId'),
        accountId: any(named: 'accountId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<TransactionEntity>>(
        transactions,
      ),
    );
  }

  void stubCategories(List<CategoryEntity> categories) {
    when(
      () => mockCategoryRepo.getCategories(
        userId: any(named: 'userId'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, List<CategoryEntity>>(categories),
    );
  }

  group('getDashboardSummary', () {
    test('should compute summary correctly with all data', () async {
      final account = AccountEntity(
        id: 'acc-1',
        userId: userId,
        name: 'Nubank',
        type: AccountType.checking,
        bank: BankType.nubank,
        initialBalance: 1000,
        createdAt: DateTime(2024),
      );

      // Two transactions in March (period), one in Feb (cumulative only)
      final transactions = [
        TransactionEntity(
          id: 'tx-feb',
          userId: userId,
          accountId: 'acc-1',
          categoryId: 'cat-salary',
          type: TransactionType.income,
          amount: 500,
          description: 'Feb salary',
          date: DateTime(2024, 2, 15),
          createdAt: DateTime(2024, 2, 15),
          updatedAt: DateTime(2024, 2, 16),
        ),
        TransactionEntity(
          id: 'tx-income',
          userId: userId,
          accountId: 'acc-1',
          categoryId: 'cat-salary',
          type: TransactionType.income,
          amount: 3000,
          description: 'March salary',
          date: DateTime(2024, 3, 5),
          createdAt: DateTime(2024, 3, 5),
          updatedAt: DateTime(2024, 3, 6),
        ),
        TransactionEntity(
          id: 'tx-expense',
          userId: userId,
          accountId: 'acc-1',
          categoryId: 'cat-food',
          type: TransactionType.expense,
          amount: 200,
          description: 'Groceries',
          date: DateTime(2024, 3, 10),
          createdAt: DateTime(2024, 3, 10),
          updatedAt: DateTime(2024, 3, 11),
        ),
      ];

      const categories = [
        CategoryEntity(
          id: 'cat-salary',
          name: 'Salary',
          icon: 58332,
          color: 4283215696,
          type: CategoryType.income,
        ),
        CategoryEntity(
          id: 'cat-food',
          name: 'Food',
          icon: 58746,
          color: 4294198070,
          type: CategoryType.expense,
        ),
      ];

      stubAccounts([account]);
      stubTransactions(transactions);
      stubCategories(categories);

      final result = await repository.getDashboardSummary(
        userId: userId,
        month: month,
      );

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (summary) {
          // Cumulative: 500 + 3000 - 200 = 3300
          // Account balance: 1000 + 3300 = 4300
          expect(summary.totalBalance, 4300);
          // Period only (June): income 3000, expense 200
          expect(summary.totalIncome, 3000);
          expect(summary.totalExpenses, 200);
          expect(summary.netResult, 2800);
          // Adjusted account
          expect(summary.accounts.length, 1);
          expect(summary.accounts.first.initialBalance, 4300);
          // Category breakdowns (June only)
          expect(summary.expensesByCategory.length, 1);
          expect(
            summary.expensesByCategory.first.categoryName,
            'Food',
          );
          expect(summary.incomeByCategory.length, 1);
          expect(
            summary.incomeByCategory.first.categoryName,
            'Salary',
          );
        },
      );
    });

    test('should sort categories descending by amount', () async {
      stubAccounts([]);
      stubTransactions([
        TransactionFactory.expense(
          id: 'tx-1',
          categoryId: 'cat-food',
          amount: 100,
        ),
        TransactionFactory.expense(
          id: 'tx-2',
          categoryId: 'cat-transport',
          amount: 300,
        ),
      ]);
      stubCategories(const [
        CategoryEntity(
          id: 'cat-food',
          name: 'Food',
          icon: 58332,
          color: 4280391411,
          type: CategoryType.expense,
        ),
        CategoryEntity(
          id: 'cat-transport',
          name: 'Transport',
          icon: 58332,
          color: 4294198070,
          type: CategoryType.expense,
        ),
      ]);

      final result = await repository.getDashboardSummary(
        userId: userId,
        month: month,
      );

      result.fold(
        (_) => fail('Expected Right'),
        (summary) {
          expect(summary.expensesByCategory.length, 2);
          // Transport (300) should be first
          expect(
            summary.expensesByCategory.first.categoryName,
            'Transport',
          );
          expect(
            summary.expensesByCategory.last.categoryName,
            'Food',
          );
        },
      );
    });

    test('should use fallback for missing category', () async {
      stubAccounts([]);
      stubTransactions([
        TransactionFactory.expense(
          id: 'tx-1',
          categoryId: 'cat-deleted',
          amount: 50,
        ),
      ]);
      stubCategories(const []);

      final result = await repository.getDashboardSummary(
        userId: userId,
        month: month,
      );

      result.fold(
        (_) => fail('Expected Right'),
        (summary) {
          expect(summary.expensesByCategory.length, 1);
          expect(
            summary.expensesByCategory.first.categoryName,
            'Sem categoria',
          );
          expect(
            summary.expensesByCategory.first.categoryColor,
            0xFF9E9E9E,
          );
        },
      );
    });

    test('should return empty summary when no data', () async {
      stubAccounts([]);
      stubTransactions([]);
      stubCategories(const []);

      final result = await repository.getDashboardSummary(
        userId: userId,
        month: month,
      );

      result.fold(
        (_) => fail('Expected Right'),
        (summary) {
          expect(summary.totalBalance, 0);
          expect(summary.totalIncome, 0);
          expect(summary.totalExpenses, 0);
          expect(summary.netResult, 0);
          expect(summary.accounts, isEmpty);
          expect(summary.expensesByCategory, isEmpty);
          expect(summary.incomeByCategory, isEmpty);
          // 50/30/20 is wired in even on the empty path so the dashboard
          // card has a safe default — see specs/fifty_thirty_twenty.md §3.
          expect(summary.fiftyThirtyTwenty.income, 0);
          expect(summary.fiftyThirtyTwenty.hasData, isFalse);
        },
      );
    });

    test('should populate fiftyThirtyTwenty from period data', () async {
      final accounts = [
        AccountEntity(
          id: 'acc-chk',
          userId: userId,
          name: 'Nubank',
          type: AccountType.checking,
          bank: BankType.nubank,
          initialBalance: 0,
          createdAt: DateTime(2024),
        ),
        AccountEntity(
          id: 'acc-inv',
          userId: userId,
          name: 'XP',
          type: AccountType.investment,
          bank: BankType.xp,
          initialBalance: 0,
          createdAt: DateTime(2024),
        ),
      ];

      // March: income 5000, needs 2500 (cat-needs), wants 1500 (cat-wants),
      // savings 1000 (checking → investment transfer).
      final transactions = [
        TransactionEntity(
          id: 'tx-income',
          userId: userId,
          accountId: 'acc-chk',
          categoryId: 'cat-salary',
          type: TransactionType.income,
          amount: 5000,
          description: 'Salário',
          date: DateTime(2024, 3, 5),
          createdAt: DateTime(2024, 3, 5),
          updatedAt: DateTime(2024, 3, 5),
        ),
        TransactionEntity(
          id: 'tx-needs',
          userId: userId,
          accountId: 'acc-chk',
          categoryId: 'cat-needs',
          type: TransactionType.expense,
          amount: 2500,
          description: 'Aluguel',
          date: DateTime(2024, 3, 10),
          createdAt: DateTime(2024, 3, 10),
          updatedAt: DateTime(2024, 3, 10),
        ),
        TransactionEntity(
          id: 'tx-wants',
          userId: userId,
          accountId: 'acc-chk',
          categoryId: 'cat-wants',
          type: TransactionType.expense,
          amount: 1500,
          description: 'Lazer',
          date: DateTime(2024, 3, 12),
          createdAt: DateTime(2024, 3, 12),
          updatedAt: DateTime(2024, 3, 12),
        ),
        TransactionEntity(
          id: 'tx-transfer-exp',
          userId: userId,
          accountId: 'acc-chk',
          categoryId: '',
          type: TransactionType.expense,
          amount: 1000,
          description: 'Aporte',
          date: DateTime(2024, 3, 15),
          linkedTransactionId: 'tx-transfer-inc',
          createdAt: DateTime(2024, 3, 15),
          updatedAt: DateTime(2024, 3, 15),
        ),
        TransactionEntity(
          id: 'tx-transfer-inc',
          userId: userId,
          accountId: 'acc-inv',
          categoryId: '',
          type: TransactionType.income,
          amount: 1000,
          description: 'Aporte',
          date: DateTime(2024, 3, 15),
          linkedTransactionId: 'tx-transfer-exp',
          createdAt: DateTime(2024, 3, 15),
          updatedAt: DateTime(2024, 3, 15),
        ),
      ];

      stubAccounts(accounts);
      stubTransactions(transactions);
      stubCategories(const [
        CategoryEntity(
          id: 'cat-salary',
          name: 'Salário',
          icon: 58332,
          color: 4283215696,
          type: CategoryType.income,
        ),
        CategoryEntity(
          id: 'cat-needs',
          name: 'Aluguel',
          icon: 58332,
          color: 4280391411,
          type: CategoryType.expense,
          bucket: CategoryBucket.needs,
        ),
        CategoryEntity(
          id: 'cat-wants',
          name: 'Lazer',
          icon: 58332,
          color: 4280391411,
          type: CategoryType.expense,
          bucket: CategoryBucket.wants,
        ),
      ]);

      final result = await repository.getDashboardSummary(
        userId: userId,
        month: month,
      );

      result.fold(
        (_) => fail('Expected Right'),
        (summary) {
          final overview = summary.fiftyThirtyTwenty;
          expect(overview.income, 5000);
          expect(overview.needsSpent, 2500);
          expect(overview.wantsSpent, 1500);
          expect(overview.savingsAmount, 1000);
          expect(overview.hasInvestmentAccount, isTrue);
          expect(overview.unclassifiedSpent, 0);
        },
      );
    });

    test('should return failure when accounts fail', () async {
      when(
        () => mockAccountRepo.getAccounts(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<AccountEntity>>(
          ServerFailure(),
        ),
      );
      stubTransactions([]);
      stubCategories(const []);

      final result = await repository.getDashboardSummary(
        userId: userId,
        month: month,
      );

      expect(result, isA<Left<Failure, DashboardSummary>>());
    });

    test('should return failure when transactions fail', () async {
      stubAccounts([]);
      when(
        () => mockTransactionRepo.getTransactions(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          categoryId: any(named: 'categoryId'),
          accountId: any(named: 'accountId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<TransactionEntity>>(
          ServerFailure(),
        ),
      );
      stubCategories(const []);

      final result = await repository.getDashboardSummary(
        userId: userId,
        month: month,
      );

      expect(result, isA<Left<Failure, DashboardSummary>>());
    });

    test('should return failure when categories fail', () async {
      stubAccounts([]);
      stubTransactions([]);
      when(
        () => mockCategoryRepo.getCategories(
          userId: any(named: 'userId'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<CategoryEntity>>(
          ServerFailure(),
        ),
      );

      final result = await repository.getDashboardSummary(
        userId: userId,
        month: month,
      );

      expect(result, isA<Left<Failure, DashboardSummary>>());
    });

    test(
      'should compute cumulative balance for multiple accounts',
      () async {
        final accounts = [
          AccountEntity(
            id: 'acc-1',
            userId: userId,
            name: 'Nubank',
            type: AccountType.checking,
            bank: BankType.nubank,
            initialBalance: 1000,
            createdAt: DateTime(2024),
          ),
          AccountEntity(
            id: 'acc-2',
            userId: userId,
            name: 'Other Bank',
            type: AccountType.checking,
            bank: BankType.others,
            initialBalance: 2000,
            createdAt: DateTime(2024),
          ),
        ];

        final transactions = [
          TransactionEntity(
            id: 'tx-1',
            userId: userId,
            accountId: 'acc-1',
            categoryId: 'cat-1',
            type: TransactionType.income,
            amount: 500,
            description: 'Income acc-1',
            date: DateTime(2024, 3, 5),
            createdAt: DateTime(2024, 3, 5),
            updatedAt: DateTime(2024, 3, 5),
          ),
          TransactionEntity(
            id: 'tx-2',
            userId: userId,
            accountId: 'acc-2',
            categoryId: 'cat-1',
            type: TransactionType.expense,
            amount: 300,
            description: 'Expense acc-2',
            date: DateTime(2024, 3, 10),
            createdAt: DateTime(2024, 3, 10),
            updatedAt: DateTime(2024, 3, 10),
          ),
        ];

        stubAccounts(accounts);
        stubTransactions(transactions);
        stubCategories(const [
          CategoryEntity(
            id: 'cat-1',
            name: 'General',
            icon: 58332,
            color: 4280391411,
            type: CategoryType.expense,
          ),
        ]);

        final result = await repository.getDashboardSummary(
          userId: userId,
          month: month,
        );

        result.fold(
          (_) => fail('Expected Right'),
          (summary) {
            // acc-1: 1000 + 500 = 1500
            // acc-2: 2000 - 300 = 1700
            // Total: 3200
            expect(summary.totalBalance, 3200);
            expect(summary.accounts.length, 2);

            final acc1 = summary.accounts.firstWhere(
              (a) => a.id == 'acc-1',
            );
            final acc2 = summary.accounts.firstWhere(
              (a) => a.id == 'acc-2',
            );
            expect(acc1.initialBalance, 1500);
            expect(acc2.initialBalance, 1700);
          },
        );
      },
    );

    test(
      'should not include prior month transactions in period totals',
      () async {
        final account = AccountEntity(
          id: 'acc-1',
          userId: userId,
          name: 'Nubank',
          type: AccountType.checking,
          bank: BankType.nubank,
          initialBalance: 0,
          createdAt: DateTime(2024),
        );

        final transactions = [
          TransactionEntity(
            id: 'tx-feb',
            userId: userId,
            accountId: 'acc-1',
            categoryId: 'cat-1',
            type: TransactionType.income,
            amount: 1000,
            description: 'Feb income',
            date: DateTime(2024, 2, 15),
            createdAt: DateTime(2024, 2, 15),
            updatedAt: DateTime(2024, 2, 15),
          ),
          TransactionEntity(
            id: 'tx-mar',
            userId: userId,
            accountId: 'acc-1',
            categoryId: 'cat-1',
            type: TransactionType.income,
            amount: 500,
            description: 'Mar income',
            date: DateTime(2024, 3, 5),
            createdAt: DateTime(2024, 3, 5),
            updatedAt: DateTime(2024, 3, 5),
          ),
        ];

        stubAccounts([account]);
        stubTransactions(transactions);
        stubCategories(const [
          CategoryEntity(
            id: 'cat-1',
            name: 'Salary',
            icon: 58332,
            color: 4280391411,
            type: CategoryType.income,
          ),
        ]);

        final result = await repository.getDashboardSummary(
          userId: userId,
          month: month,
        );

        result.fold(
          (_) => fail('Expected Right'),
          (summary) {
            // Period income only March: 500
            expect(summary.totalIncome, 500);
            // Cumulative balance: 0 + 1000 + 500 = 1500
            expect(summary.totalBalance, 1500);
          },
        );
      },
    );

    test(
      'should exclude transfers from totals and category breakdowns',
      () async {
        final accounts = [
          AccountEntity(
            id: 'acc-1',
            userId: userId,
            name: 'Nubank',
            type: AccountType.checking,
            bank: BankType.nubank,
            initialBalance: 5000,
            createdAt: DateTime(2024),
          ),
          AccountEntity(
            id: 'acc-2',
            userId: userId,
            name: 'Inter',
            type: AccountType.checking,
            bank: BankType.others,
            initialBalance: 1000,
            createdAt: DateTime(2024),
          ),
        ];

        final transfer = TransactionFactory.transfer(
          amount: 2000,
          date: DateTime(2024, 3, 15),
        );

        final transactions = [
          TransactionFactory.expense(
            id: 'tx-real-expense',
            categoryId: 'cat-food',
            amount: 300,
            date: DateTime(2024, 3, 10),
          ),
          transfer.expense,
          transfer.income,
        ];

        stubAccounts(accounts);
        stubTransactions(transactions);
        stubCategories(const [
          CategoryEntity(
            id: 'cat-food',
            name: 'Food',
            icon: 58332,
            color: 4294198070,
            type: CategoryType.expense,
          ),
        ]);

        final result = await repository.getDashboardSummary(
          userId: userId,
          month: month,
        );

        result.fold(
          (_) => fail('Expected Right'),
          (summary) {
            // Only real expense counts, not transfer
            expect(summary.totalExpenses, 300);
            expect(summary.totalIncome, 0);
            expect(summary.netResult, -300);
            // Category breakdown: only food expense, no "Sem categoria"
            expect(summary.expensesByCategory.length, 1);
            expect(
              summary.expensesByCategory.first.categoryName,
              'Food',
            );
            expect(summary.incomeByCategory, isEmpty);
          },
        );
      },
    );
  });
}
