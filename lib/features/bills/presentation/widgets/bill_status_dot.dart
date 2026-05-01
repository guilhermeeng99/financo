import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:flutter/material.dart';

/// Visual taxonomy for a bill — the single source of truth that maps a bill
/// to the color/label used across summary, headers and tiles. Keeping it in
/// one place avoids the previous drift where the tile, dialog, and section
/// headers each reasoned about color independently.
enum BillStatusKind { overdue, today, upcoming, paid }

extension BillStatusKindX on BillEntity {
  BillStatusKind get statusKind {
    if (isPaid) return BillStatusKind.paid;
    if (isOverdue) return BillStatusKind.overdue;
    if (isDueToday) return BillStatusKind.today;
    return BillStatusKind.upcoming;
  }
}

Color billStatusColor(
  BuildContext context,
  BillStatusKind kind, {
  bool isReceivable = false,
}) {
  final colors = context.appColors;
  switch (kind) {
    case BillStatusKind.overdue:
      return colors.expense;
    case BillStatusKind.today:
      return colors.warning;
    case BillStatusKind.upcoming:
      return isReceivable ? colors.income : colors.primary;
    case BillStatusKind.paid:
      return colors.onBackgroundLight;
  }
}
