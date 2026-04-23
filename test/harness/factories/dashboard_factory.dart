import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardFactory {
  const DashboardFactory._();

  static CategoryAmount categoryAmount({
    String categoryId = 'cat-1',
    String categoryName = 'Food',
    int categoryColor = 4280391411,
    double amount = 150,
  }) {
    return CategoryAmount(
      categoryId: categoryId,
      categoryName: categoryName,
      categoryColor: categoryColor,
      amount: amount,
    );
  }

  static DashboardSummary summary({
    double totalBalance = 5000,
    double totalIncome = 3000,
    double totalExpenses = 2000,
    double netResult = 1000,
    List<AccountEntity>? accounts,
    List<CategoryAmount>? expensesByCategory,
    List<CategoryAmount>? incomeByCategory,
  }) {
    return DashboardSummary(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netResult: netResult,
      accounts:
          accounts ??
          [
            AccountEntity(
              id: 'acc-1',
              userId: 'user-1',
              name: 'Nubank',
              type: AccountType.checking,
              bank: BankType.nubank,
              initialBalance: 5000,
              createdAt: DateTime(2024),
            ),
          ],
      expensesByCategory:
          expensesByCategory ??
          [
            const CategoryAmount(
              categoryId: 'cat-food',
              categoryName: 'Food',
              categoryColor: 4280391411,
              amount: 1200,
            ),
            const CategoryAmount(
              categoryId: 'cat-transport',
              categoryName: 'Transport',
              categoryColor: 4294198070,
              amount: 800,
            ),
          ],
      incomeByCategory:
          incomeByCategory ??
          [
            const CategoryAmount(
              categoryId: 'cat-salary',
              categoryName: 'Salary',
              categoryColor: 4283215696,
              amount: 3000,
            ),
          ],
    );
  }

  static DashboardSummary empty() {
    return const DashboardSummary(
      totalBalance: 0,
      totalIncome: 0,
      totalExpenses: 0,
      netResult: 0,
      accounts: [],
      expensesByCategory: [],
      incomeByCategory: [],
    );
  }
}
