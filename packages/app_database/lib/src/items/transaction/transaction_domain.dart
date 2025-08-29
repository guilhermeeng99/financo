import 'package:drift/drift.dart';
import 'package:financo/app/app_theme.dart';
import 'package:flutter/material.dart' as flutter;

import '../../core/financial_type.dart';
import '../account/account_domain.dart';
import '../category/category_domain.dart';

enum TransactionPaymentStatus {
  paid('paid'),
  unpaid('unpaid');

  const TransactionPaymentStatus(this.value);
  final String value;
}

enum TransactionRecurrenceType {
  unique('unique'),
  fixed('fixed');

  const TransactionRecurrenceType(this.value);
  final String value;
}

enum TransactionRecurrenceFrequency {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const TransactionRecurrenceFrequency(this.value);
  final String value;
}

@UseRowClass(TransactionData)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionType => textEnum<FinancialType>()();
  DateTimeColumn get actualDate => dateTime()();
  DateTimeColumn get competenceDate => dateTime()();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(max: 255)();
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
      transactionType: transactionType ?? this.transactionType,
      description: description ?? this.description,
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

  double get absoluteAmount => amount.abs();
}

extension TransactionPaymentStatusExtension on TransactionPaymentStatus {
  flutter.Color getColor(flutter.BuildContext context) {
    switch (this) {
      case TransactionPaymentStatus.paid:
        return flutter.Theme.of(context).customColors.button01;
      case TransactionPaymentStatus.unpaid:
        return flutter.Theme.of(context).customColors.button02;
    }
  }
}

extension TransactionRecurrenceTypeExtension on TransactionRecurrenceType {
  String get displayName {
    switch (this) {
      case TransactionRecurrenceType.unique:
        return 'Única';
      case TransactionRecurrenceType.fixed:
        return 'Fixa';
    }
  }
}

extension TransactionRecurrenceFrequencyExtension
    on TransactionRecurrenceFrequency {
  String get displayName {
    switch (this) {
      case TransactionRecurrenceFrequency.daily:
        return 'Diária';
      case TransactionRecurrenceFrequency.weekly:
        return 'Semanal';
      case TransactionRecurrenceFrequency.monthly:
        return 'Mensal';
      case TransactionRecurrenceFrequency.yearly:
        return 'Anual';
    }
  }
}

extension AmountColorExtension on double {
  flutter.Color getColor(flutter.BuildContext context) {
    if (this < 0) {
      return flutter.Theme.of(context).customColors.expense;
    } else {
      return flutter.Theme.of(context).customColors.income;
    }
  }
}
