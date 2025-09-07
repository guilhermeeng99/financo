import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart' as flutter;

extension TransactionPaymentStatusExtension on TransactionPaymentStatus {
  flutter.Color getColor(flutter.BuildContext context) {
    switch (this) {
      case TransactionPaymentStatus.paid:
        return flutter.Theme.of(context).customColors.button01;
      case TransactionPaymentStatus.unpaid:
        return flutter.Theme.of(context).customColors.button02;
    }
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
