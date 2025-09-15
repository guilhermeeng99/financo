import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

enum TransactionFilterType { pending, unpaid, paid }

extension TransactionFilterTypeExtension on TransactionFilterType {
  String title(BuildContext context) {
    switch (this) {
      case TransactionFilterType.pending:
        return context.t.common.labels.pending(n: 1);
      case TransactionFilterType.paid:
        return context.t.transactions.status_type.paid;
      case TransactionFilterType.unpaid:
        return context.t.transactions.status_type.unpaid;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case TransactionFilterType.pending:
        return TransactionStatusColors.getColorForStatus(
          context,
          TransactionPaymentStatus.unpaid,
          isOverdue: true,
        );
      case TransactionFilterType.paid:
        return TransactionStatusColors.getColorForStatus(
          context,
          TransactionPaymentStatus.paid,
        );
      case TransactionFilterType.unpaid:
        return TransactionStatusColors.getColorForStatus(
          context,
          TransactionPaymentStatus.unpaid,
        );
    }
  }

  bool matchesTransaction(TransactionI transaction) {
    switch (this) {
      case TransactionFilterType.pending:
        return transaction.t.isOverdue;
      case TransactionFilterType.paid:
        return transaction.t.paymentStatus == TransactionPaymentStatus.paid;
      case TransactionFilterType.unpaid:
        return transaction.t.paymentStatus == TransactionPaymentStatus.unpaid &&
            !transaction.t.isOverdue;
    }
  }
}
