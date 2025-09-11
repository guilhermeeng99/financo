import 'package:app_database/src/items/account/index.dart';
import 'package:app_database/src/items/category/index.dart';
import 'package:drift/drift.dart';

import '../../../core/financial_type.dart';
import 'transaction_enums.dart';

@UseRowClass(DataTransaction)
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
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  // Target account when transferring between accounts (optional)
  IntColumn get targetAccountId =>
      integer().nullable().references(Accounts, #id)();
  // Logical identifier that groups the two transactions (outgoing and incoming) of a transfer
  TextColumn get transferId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DataTransaction extends BaseTransaction {
  DataTransaction({
    required super.id,
    required super.transactionType,
    required super.actualDate,
    required super.competenceDate,
    required super.amount,
    required super.paymentStatus,
    required super.recurrenceType,
    required super.accountId,
    required super.createdAt,
    required super.updatedAt,
    super.recurrenceFrequency,
    super.description,
    this.categoryId,
    this.targetAccountId,
    this.transferId,
  });

  final int? categoryId;
  final int? targetAccountId;
  final String? transferId;
}

class TransactionI {
  TransactionI({
    required this.t,
    required this.accountName,
    this.categoryName,
    this.otherAccount,
  });

  final DataTransaction t;
  final String accountName;
  final String? categoryName;
  final String? otherAccount;

  String get otherAccountName {
    if (t.transactionType == FinancialType.expense) {
      return '→ $otherAccount';
    } else {
      return '← $otherAccount';
    }
  }
}

abstract class BaseTransaction {
  const BaseTransaction({
    required this.id,
    required this.actualDate,
    required this.competenceDate,
    required this.transactionType,
    required this.amount,
    required this.paymentStatus,
    required this.recurrenceType,
    required this.accountId,
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
  final DateTime createdAt;
  final DateTime updatedAt;
}

class StandardTransaction extends BaseTransaction {
  const StandardTransaction({
    required super.id,
    required super.actualDate,
    required super.competenceDate,
    required super.transactionType,
    required super.amount,
    required super.paymentStatus,
    required super.recurrenceType,
    required super.accountId,
    required super.createdAt,
    required super.updatedAt,
    required this.categoryId,
    super.description,
    super.recurrenceFrequency,
  });

  factory StandardTransaction.fromDataTransaction(DataTransaction data) {
    if (data.categoryId == null) {
      throw ArgumentError(
        'DataTransaction must have categoryId to convert to StandardTransaction',
      );
    }

    return StandardTransaction(
      id: data.id,
      actualDate: data.actualDate,
      competenceDate: data.competenceDate,
      transactionType: data.transactionType,
      amount: data.amount,
      paymentStatus: data.paymentStatus,
      recurrenceType: data.recurrenceType,
      accountId: data.accountId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      categoryId: data.categoryId!,
      description: data.description,
      recurrenceFrequency: data.recurrenceFrequency,
    );
  }

  final int categoryId;
}

class TransferTransaction extends BaseTransaction {
  const TransferTransaction({
    required super.id,
    required super.actualDate,
    required super.competenceDate,
    required super.transactionType,
    required super.amount,
    required super.paymentStatus,
    required super.recurrenceType,
    required super.accountId,
    required super.createdAt,
    required super.updatedAt,
    required this.targetAccountId,
    required this.transferId,
    super.description,
    super.recurrenceFrequency,
  });

  factory TransferTransaction.fromDataTransaction(DataTransaction data) {
    if (data.targetAccountId == null || data.transferId == null) {
      throw ArgumentError(
        'DataTransaction must have targetAccountId and transferId to convert to TransferTransaction',
      );
    }

    return TransferTransaction(
      id: data.id,
      actualDate: data.actualDate,
      competenceDate: data.competenceDate,
      transactionType: data.transactionType,
      amount: data.amount,
      paymentStatus: data.paymentStatus,
      recurrenceType: data.recurrenceType,
      accountId: data.accountId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      targetAccountId: data.targetAccountId!,
      transferId: data.transferId!,
      description: data.description,
      recurrenceFrequency: data.recurrenceFrequency,
    );
  }

  final int targetAccountId;
  final String transferId;
}
