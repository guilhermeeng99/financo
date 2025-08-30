import 'package:drift/drift.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart' as flutter;

import '../../core/exceptions.dart';
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
}

class TransactionAmount {
  factory TransactionAmount.create(double value) {
    if (value.isNaN || value.isInfinite) {
      throw const ValidationException(
        'Transaction amount must be a valid number',
      );
    }

    if (value == 0) {
      throw const ValidationException(
        'Transaction amount must be different than zero',
      );
    }

    return TransactionAmount._(value);
  }

  TransactionAmount._(this.value);

  final double value;
}

class TransactionDescription {
  factory TransactionDescription.create(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.length > 255) {
      throw const ValidationException(
        'Transaction description must be at most 255 characters long',
      );
    }

    return TransactionDescription._(trimmedValue);
  }

  TransactionDescription._(this.value);

  final String value;
}

class TransactionAccountId {
  factory TransactionAccountId.create(int value) {
    if (value <= 0) {
      throw const ValidationException('Account ID must be a positive number');
    }

    return TransactionAccountId._(value);
  }

  TransactionAccountId._(this.value);

  final int value;
}

class TransactionCategoryId {
  factory TransactionCategoryId.create(int value) {
    if (value <= 0) {
      throw const ValidationException('Category ID must be a positive number');
    }

    return TransactionCategoryId._(value);
  }

  TransactionCategoryId._(this.value);

  final int value;
}

class TransactionDate {
  factory TransactionDate.create(DateTime value) {
    final minimumDate = DateTime.now().subtract(const Duration(days: 36500));
    if (value.isBefore(minimumDate)) {
      throw const ValidationException(
        'Transaction date cannot be more than 100 years in the past',
      );
    }

    final maximumDate = DateTime.now().add(const Duration(days: 3650));
    if (value.isAfter(maximumDate)) {
      throw const ValidationException(
        'Transaction date cannot be more than 10 years in the future',
      );
    }

    return TransactionDate._(value);
  }

  TransactionDate._(this.value);

  final DateTime value;
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
  String displayName(flutter.BuildContext context) {
    switch (this) {
      case TransactionRecurrenceType.unique:
        return context.t.transactions.recurrence_type.unique;
      case TransactionRecurrenceType.fixed:
        return context.t.transactions.recurrence_type.fixed;
    }
  }
}

extension TransactionRecurrenceFrequencyExtension
    on TransactionRecurrenceFrequency {
  String displayName(flutter.BuildContext context) {
    switch (this) {
      case TransactionRecurrenceFrequency.daily:
        return context.t.common.frequency.daily;
      case TransactionRecurrenceFrequency.weekly:
        return context.t.common.frequency.weekly;
      case TransactionRecurrenceFrequency.monthly:
        return context.t.common.frequency.monthly;
      case TransactionRecurrenceFrequency.yearly:
        return context.t.common.frequency.yearly;
    }
  }
}
