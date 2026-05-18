import 'package:equatable/equatable.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';

class CategoryAmount extends Equatable {
  const CategoryAmount({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
  });

  final String categoryId;
  final String categoryName;
  final int categoryColor;
  final double amount;

  @override
  List<Object> get props => [categoryId, categoryName, categoryColor, amount];
}

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netResult,
    required this.accounts,
    required this.expensesByCategory,
    required this.incomeByCategory,
    required this.fiftyThirtyTwenty,
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final double netResult;
  final List<AccountEntity> accounts;
  final List<CategoryAmount> expensesByCategory;
  final List<CategoryAmount> incomeByCategory;

  /// Per-period 50/30/20 split. Computed by `compute50_30_20Overview`
  /// inside the repository so callers don't need to compose it. See
  /// `specs/fifty_thirty_twenty.md`.
  final FiftyThirtyTwentyOverview fiftyThirtyTwenty;

  @override
  List<Object> get props => [
    totalBalance,
    totalIncome,
    totalExpenses,
    netResult,
    accounts,
    expensesByCategory,
    incomeByCategory,
    fiftyThirtyTwenty,
  ];
}
