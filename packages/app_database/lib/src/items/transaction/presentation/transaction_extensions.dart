import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart' as flutter;

extension DataTransactionExtension on DataTransaction {
  bool get isTransfer => transferId != null && targetAccountId != null;

  bool get isOverdue {
    final now = DateTime.now();
    return paymentStatus == TransactionPaymentStatus.unpaid &&
        now.isAfter(actualDate);
  }

  flutter.Color getStatusColor(flutter.BuildContext context) {
    return TransactionStatusColors.getColorForStatus(
      context,
      paymentStatus,
      isOverdue: isOverdue,
    );
  }
}

class TransactionStatusColors {
  static flutter.Color getColorForStatus(
    flutter.BuildContext context,
    TransactionPaymentStatus status, {
    bool isOverdue = false,
  }) {
    if (isOverdue) {
      return flutter.Theme.of(context).customColors.expense;
    }

    switch (status) {
      case TransactionPaymentStatus.paid:
        return flutter.Theme.of(context).customColors.income;
      case TransactionPaymentStatus.unpaid:
        return flutter.Theme.of(context).customColors.pending;
    }
  }
}

extension TransactionPaymentStatusExtension on TransactionPaymentStatus {
  flutter.Color getColor(
    flutter.BuildContext context, {
    DataTransaction? transaction,
  }) {
    return TransactionStatusColors.getColorForStatus(
      context,
      this,
      isOverdue: transaction?.isOverdue ?? false,
    );
  }

  String title(flutter.BuildContext context) {
    switch (this) {
      case TransactionPaymentStatus.paid:
        return context.t.transactions.status_type.paid;
      case TransactionPaymentStatus.unpaid:
        return context.t.transactions.status_type.unpaid;
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
