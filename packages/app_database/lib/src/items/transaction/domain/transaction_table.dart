import 'package:app_database/src/items/account/index.dart';
import 'package:app_database/src/items/category/index.dart';
import 'package:drift/drift.dart';

import '../../../core/financial_type.dart';
import 'transaction_enums.dart';

@UseRowClass(TransactionData)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionType => textEnum<FinancialType>()();
  DateTimeColumn get actualDate => dateTime()();
  DateTimeColumn get competenceDate => dateTime()();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(max: 255).nullable()();
  TextColumn get paymentStatus => textEnum<TransactionPaymentStatus>()();
  TextColumn get recurrenceType => textEnum<TransactionRecurrenceType>()();
  TextColumn get recurrenceFrequency =>
      textEnum<TransactionRecurrenceFrequency>().nullable()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class TransactionData {
  TransactionData({
    required this.id,
    required this.actualDate,
    required this.transactionType,
    required this.competenceDate,
    required this.amount,
    required this.paymentStatus,
    required this.recurrenceType,
    required this.accountId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.recurrenceFrequency,
  });

  final int id;
  final DateTime actualDate;
  final DateTime competenceDate;
  final FinancialType transactionType;
  final double amount;
  final String? description;
  final TransactionPaymentStatus paymentStatus;
  final TransactionRecurrenceType recurrenceType;
  final TransactionRecurrenceFrequency? recurrenceFrequency;
  final int accountId;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
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
