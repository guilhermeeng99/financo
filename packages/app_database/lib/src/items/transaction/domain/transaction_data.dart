import '../../../core/financial_type.dart';
import 'transaction_enums.dart';

class TransactionData {
  TransactionData({
    required this.id,
    required this.actualDate,
    required this.transactionType,
    required this.competenceDate,
    required this.amount,
    required this.description,
    required this.paymentStatus,
    required this.recurrenceType,
    required this.accountId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.recurrenceFrequency,
  });

  final int id;
  final DateTime actualDate;
  final DateTime competenceDate;
  final FinancialType transactionType;
  final double amount;
  final String description;
  final TransactionPaymentStatus paymentStatus;
  final TransactionRecurrenceType recurrenceType;
  final TransactionRecurrenceFrequency? recurrenceFrequency;
  final int accountId;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionData copyWith({
    int? id,
    DateTime? actualDate,
    DateTime? competenceDate,
    double? amount,
    String? description,
    FinancialType? transactionType,
    TransactionPaymentStatus? paymentStatus,
    TransactionRecurrenceType? recurrenceType,
    TransactionRecurrenceFrequency? recurrenceFrequency,
    int? accountId,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionData(
      id: id ?? this.id,
      actualDate: actualDate ?? this.actualDate,
      competenceDate: competenceDate ?? this.competenceDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionType: transactionType ?? this.transactionType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TransactionData{'
        'id: $id, '
        'actualDate: $actualDate, '
        'competenceDate: $competenceDate, '
        'transactionType: $transactionType, '
        'amount: $amount, '
        'description: $description, '
        'paymentStatus: $paymentStatus, '
        'recurrenceType: $recurrenceType, '
        'recurrenceFrequency: $recurrenceFrequency, '
        'accountId: $accountId, '
        'categoryId: $categoryId, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        '}';
  }
}

class TransactionI {
  TransactionI({
    required this.t,
    required this.accountName,
    required this.categoryName,
  });

  final TransactionData t;
  final String accountName;
  final String categoryName;
}
