import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netResult,
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final double netResult;

  @override
  List<Object> get props => [
    totalBalance,
    totalIncome,
    totalExpenses,
    netResult,
  ];
}
