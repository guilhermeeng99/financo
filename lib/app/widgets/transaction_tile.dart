import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Single row representing a transaction. Used by:
///   - the transactions list page
///   - the accounts statement page (passes [categoryLabel])
///   - the payables/receivables pages with settlement status enabled
///
/// Shows a type-tinted icon disc (income/expense/transfer), description on
/// top, and a contextual subtitle below combining date + optional category
/// and account labels. Amount on the right is colored by [AmountText].
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    this.categoryLabel,
    this.accountLabel,
    this.showSettlementStatus = false,
    this.onTap,
    super.key,
  });

  final TransactionEntity transaction;

  /// Optional secondary label appended to the date, e.g. category name or
  /// "Source → Destination" for transfers.
  final String? categoryLabel;

  /// Optional tertiary label for the account when available.
  final String? accountLabel;

  /// Shows pending/paid status in icon and subtitle when the host page needs it.
  final bool showSettlementStatus;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isIncome = transaction.type == TransactionType.income;
    final visual = showSettlementStatus
        ? _statementVisualFor(transaction, colors)
        : _defaultVisualFor(transaction, colors);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              _IconDisc(icon: visual.icon, color: visual.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Descriptions are optional now — when blank we drop the
                    // title row entirely instead of falling back to a generic
                    // "Expense"/"Income"/"Transfer" label, which was just
                    // restating the type already shown by the colored icon.
                    if (transaction.description.isNotEmpty) ...[
                      Text(
                        transaction.description,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      _subtitleFor(transaction),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: showSettlementStatus && transaction.isOverdue
                            ? colors.expense
                            : colors.onBackgroundLight,
                        fontWeight:
                            showSettlementStatus && transaction.isOverdue
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AmountText(
                amount: isIncome ? transaction.amount : -transaction.amount,
                fontSize: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleFor(TransactionEntity tx) {
    final date = formatDayMonth(tx.isPending ? tx.dueDate : tx.date);
    final parts = <String>[date];
    if (categoryLabel != null && categoryLabel!.isNotEmpty) {
      parts.add(categoryLabel!);
    }
    if (accountLabel != null && accountLabel!.isNotEmpty) {
      parts.add(accountLabel!);
    }
    if (showSettlementStatus) {
      parts.add(_settlementLabel(tx));
    }
    return parts.join(' · ');
  }

  String _settlementLabel(TransactionEntity tx) {
    if (tx.isPaid) {
      return tx.isReceivable
          ? t.payablesReceivables.received
          : t.payablesReceivables.paid;
    }
    if (tx.isOverdue) return t.payablesReceivables.overdue;
    if (tx.isDueToday) return t.payablesReceivables.dueToday;
    return t.payablesReceivables.scheduled;
  }
}

({FaIconData icon, Color color}) _defaultVisualFor(
  TransactionEntity transaction,
  AppColorsData colors,
) {
  if (transaction.isTransfer) {
    return (icon: FontAwesomeIcons.arrowRightArrowLeft, color: colors.primary);
  }
  if (transaction.type == TransactionType.income) {
    return (icon: FontAwesomeIcons.arrowDown, color: colors.income);
  }
  return (icon: FontAwesomeIcons.arrowUp, color: colors.expense);
}

({FaIconData icon, Color color}) _statementVisualFor(
  TransactionEntity transaction,
  AppColorsData colors,
) {
  if (transaction.isPaid) return _defaultVisualFor(transaction, colors);
  if (transaction.isOverdue) {
    return (icon: FontAwesomeIcons.triangleExclamation, color: colors.expense);
  }
  return (icon: FontAwesomeIcons.clock, color: colors.warning);
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.icon, required this.color});

  final FaIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: FaIcon(icon, size: 16, color: color)),
    );
  }
}
