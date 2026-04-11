import 'package:equatable/equatable.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';

class CategoryAmount extends Equatable {
  const CategoryAmount({
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
  });

  final String categoryName;
  final int categoryColor;
  final double amount;

  @override
  List<Object> get props => [categoryName, categoryColor, amount];
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
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final double netResult;
  final List<AccountEntity> accounts;
  final List<CategoryAmount> expensesByCategory;
  final List<CategoryAmount> incomeByCategory;

  @override
  List<Object> get props => [
    totalBalance,
    totalIncome,
    totalExpenses,
    netResult,
    accounts,
    expensesByCategory,
    incomeByCategory,
  ];
}
