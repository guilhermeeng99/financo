import 'package:app_database/app_database.dart';

class CreditCardService {
  const CreditCardService(this.transactions);

  final List<TransactionI> transactions;

  CreditCardBillCalculationResults calculateBillResults(
    DateTime closingDate,
    double? creditLimit,
  ) {
    final previousBalance = calculatePreviousBalance(closingDate);
    final totalPaid = calculateTotalPaid(closingDate);
    final totalAmount = calculateTotalAmount(closingDate);
    final currentExpenses = calculateCurrentExpenses(closingDate);
    final amountToPay = calculateAmountToPay(closingDate);
    final usedLimit = -currentExpenses;
    final availableLimit = (creditLimit ?? 0) + usedLimit;

    return CreditCardBillCalculationResults(
      previousBalance: previousBalance,
      totalPaid: totalPaid,
      totalAmount: totalAmount,
      currentExpenses: currentExpenses,
      amountToPay: amountToPay,
      creditLimit: creditLimit ?? 0,
      usedLimit: usedLimit,
      availableLimit: availableLimit,
      closingDate: closingDate,
    );
  }

  CreditCardBillDates calculateBillDates({
    required DateTime currentDate,
    required int billClosingDay,
    DateTime? firstBillDueDate,
  }) {
    final closingDate = _calculateClosingDate(currentDate, billClosingDay);
    final dueDate = _calculateDueDate(firstBillDueDate, closingDate);

    return CreditCardBillDates(
      closingDate: closingDate,
      dueDate: dueDate,
    );
  }

  double calculatePreviousBalance(DateTime closingDate) {
    final previousPeriodStart = DateTime(
      closingDate.year,
      closingDate.month - 1,
      closingDate.day,
    );

    return transactions
        .where(
          (transaction) =>
              transaction.t.createdAt.isBefore(previousPeriodStart) &&
              transaction.t.transactionType == FinancialType.expense,
        )
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.t.amount.abs(),
        );
  }

  double calculateTotalPaid(DateTime closingDate) {
    final currentPeriodStart = DateTime(
      closingDate.year,
      closingDate.month - 1,
      closingDate.day,
    );

    return transactions
        .where(
          (transaction) =>
              transaction.t.createdAt.isAfter(currentPeriodStart) &&
              transaction.t.createdAt.isBefore(closingDate) &&
              transaction.t.transactionType == FinancialType.income,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double calculateCurrentExpenses(DateTime closingDate) {
    final currentPeriodStart = DateTime(
      closingDate.year,
      closingDate.month - 1,
      closingDate.day,
    );

    return transactions
        .where(
          (transaction) =>
              transaction.t.createdAt.isAfter(currentPeriodStart) &&
              transaction.t.createdAt.isBefore(closingDate) &&
              transaction.t.transactionType == FinancialType.expense,
        )
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.t.amount.abs(),
        );
  }

  double calculateTotalAmount(DateTime closingDate) {
    final currentExpenses = calculateCurrentExpenses(closingDate);
    final totalPaid = calculateTotalPaid(closingDate);

    return totalPaid - currentExpenses;
  }

  double calculateAmountToPay(DateTime closingDate) {
    final currentPeriodStart = DateTime(
      closingDate.year,
      closingDate.month - 1,
      closingDate.day,
    );

    final paidExpenses = transactions
        .where(
          (transaction) =>
              transaction.t.createdAt.isAfter(currentPeriodStart) &&
              transaction.t.createdAt.isBefore(closingDate) &&
              transaction.t.transactionType == FinancialType.expense &&
              transaction.t.paymentStatus == TransactionPaymentStatus.paid,
        )
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.t.amount.abs(),
        );

    final paidIncomes = transactions
        .where(
          (transaction) =>
              transaction.t.createdAt.isAfter(currentPeriodStart) &&
              transaction.t.createdAt.isBefore(closingDate) &&
              transaction.t.transactionType == FinancialType.income &&
              transaction.t.paymentStatus == TransactionPaymentStatus.paid,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.t.amount);

    return paidIncomes - paidExpenses;
  }

  DateTime _calculateClosingDate(DateTime currentDate, int closingDay) {
    var closingDate = DateTime(currentDate.year, currentDate.month, closingDay);

    if (closingDate.isBefore(currentDate)) {
      closingDate = DateTime(
        currentDate.year,
        currentDate.month + 1,
        closingDay,
      );
    }

    return closingDate;
  }

  DateTime _calculateDueDate(DateTime? firstBillDueDate, DateTime closingDate) {
    if (firstBillDueDate == null) {
      return closingDate.add(const Duration(days: 7));
    }

    final dayOfMonth = firstBillDueDate.day;
    var dueDate = DateTime(closingDate.year, closingDate.month + 1, dayOfMonth);

    if (dueDate.isBefore(closingDate)) {
      dueDate = DateTime(closingDate.year, closingDate.month + 2, dayOfMonth);
    }

    return dueDate;
  }
}

class CreditCardBillCalculationResults {
  const CreditCardBillCalculationResults({
    required this.previousBalance,
    required this.totalPaid,
    required this.totalAmount,
    required this.currentExpenses,
    required this.amountToPay,
    required this.creditLimit,
    required this.usedLimit,
    required this.availableLimit,
    required this.closingDate,
  });

  final double previousBalance;
  final double totalPaid;
  final double totalAmount;
  final double currentExpenses;
  final double amountToPay;
  final double creditLimit;
  final double usedLimit;
  final double availableLimit;
  final DateTime closingDate;
}

class CreditCardBillDates {
  const CreditCardBillDates({
    required this.closingDate,
    required this.dueDate,
  });

  final DateTime closingDate;
  final DateTime dueDate;
}
