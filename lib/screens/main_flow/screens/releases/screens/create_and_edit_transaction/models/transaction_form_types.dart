import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

enum TransactionScreenType {
  income,
  expense,
  transfer;

  static TransactionScreenType fromTransaction(DataTransaction transaction) {
    if (transaction.transferId != null && transaction.targetAccountId != null) {
      return TransactionScreenType.transfer;
    }
    return _fromFinancialType(transaction.transactionType);
  }

  static TransactionScreenType _fromFinancialType(FinancialType type) {
    return switch (type) {
      FinancialType.income => TransactionScreenType.income,
      FinancialType.expense => TransactionScreenType.expense,
    };
  }

  FinancialType? get financialType => switch (this) {
    TransactionScreenType.income => FinancialType.income,
    TransactionScreenType.expense => FinancialType.expense,
    TransactionScreenType.transfer => null,
  };

  bool get isTransfer => this == TransactionScreenType.transfer;

  String displayName(BuildContext context) => switch (this) {
    TransactionScreenType.income => FinancialType.income.title(context),
    TransactionScreenType.expense => FinancialType.expense.title(context),
    TransactionScreenType.transfer => context.t.common.labels.transfers(n: 1),
  };
}

class TransactionFormData {
  TransactionFormData({
    this.description = '',
    this.amount = 0.0,
    DateTime? actualDate,
    DateTime? competenceDate,
    this.transactionScreenType = TransactionScreenType.expense,
    this.selectedTargetAccountId,
    this.paymentStatus = TransactionPaymentStatus.unpaid,
    this.recurrenceType = TransactionRecurrenceType.unique,
    this.recurrenceFrequency = TransactionRecurrenceFrequency.monthly,
    this.selectedAccountId,
    this.selectedCategoryId,
  }) : actualDate = actualDate ?? DateTime.now(),
       competenceDate = competenceDate ?? DateTime.now();

  factory TransactionFormData.fromTransaction(DataTransaction transaction) {
    return TransactionFormData(
      description: transaction.description ?? '',
      amount: transaction.amount.abs(),
      actualDate: transaction.actualDate,
      competenceDate: transaction.competenceDate,
      transactionScreenType: TransactionScreenType.fromTransaction(transaction),
      paymentStatus: transaction.paymentStatus,
      recurrenceType: transaction.recurrenceType,
      recurrenceFrequency:
          transaction.recurrenceFrequency ??
          TransactionRecurrenceFrequency.monthly,
      selectedAccountId: transaction.accountId,
      selectedCategoryId: transaction.categoryId,
      selectedTargetAccountId: transaction.targetAccountId,
    );
  }

  final String description;
  final double amount;
  final DateTime actualDate;
  final DateTime competenceDate;
  final TransactionScreenType transactionScreenType;
  final int? selectedTargetAccountId;
  final TransactionPaymentStatus paymentStatus;
  final TransactionRecurrenceType recurrenceType;
  final TransactionRecurrenceFrequency recurrenceFrequency;
  final int? selectedAccountId;
  final int? selectedCategoryId;

  bool get isTransfer => transactionScreenType.isTransfer;
  FinancialType? get selectedTransactionType =>
      transactionScreenType.financialType;

  TransactionFormData copyWith({
    String? description,
    double? amount,
    DateTime? actualDate,
    DateTime? competenceDate,
    TransactionScreenType? transactionScreenType,
    int? selectedTargetAccountId,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    TransactionRecurrenceFrequency? recurrenceFrequency,
    int? selectedAccountId,
    int? selectedCategoryId,
  }) {
    return TransactionFormData(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      actualDate: actualDate ?? this.actualDate,
      competenceDate: competenceDate ?? this.competenceDate,
      transactionScreenType:
          transactionScreenType ?? this.transactionScreenType,
      selectedTargetAccountId:
          selectedTargetAccountId ?? this.selectedTargetAccountId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      selectedAccountId: selectedAccountId ?? this.selectedAccountId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}
