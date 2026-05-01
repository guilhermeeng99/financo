import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final _dayMonthFormat = DateFormat('dd/MM');

/// Single row representing a transaction. Used by:
///   - the transactions list page
///   - the accounts statement page (passes [categoryLabel])
///   - the bills feature (linked transactions from settled bills)
///
/// Shows a type-tinted icon disc (income/expense/transfer), description on
/// top, and a contextual subtitle below combining date + optional category
/// and account labels. Amount on the right is colored by [AmountText].
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    this.categoryLabel,
    this.accountLabel,
    this.onTap,
    super.key,
  });

  final TransactionEntity transaction;

  /// Optional secondary label appended to the date, e.g. category name or
  /// "Source → Destination" for transfers.
  final String? categoryLabel;

  /// Optional tertiary label for the account when available.
  final String? accountLabel;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.isTransfer;

    final accent = isTransfer
        ? colors.primary
        : isIncome
            ? colors.income
            : colors.expense;
    final icon = isTransfer
        ? FontAwesomeIcons.arrowRightArrowLeft
        : isIncome
            ? FontAwesomeIcons.arrowDown
            : FontAwesomeIcons.arrowUp;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              _IconDisc(icon: icon, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description.isEmpty
                          ? _fallbackDescription(transaction)
                          : transaction.description,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleFor(transaction),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
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
    final date = _dayMonthFormat.format(tx.date);
    final parts = <String>[date];
    if (categoryLabel != null && categoryLabel!.isNotEmpty) {
      parts.add(categoryLabel!);
    }
    if (accountLabel != null && accountLabel!.isNotEmpty) {
      parts.add(accountLabel!);
    }
    return parts.join(' · ');
  }

  String _fallbackDescription(TransactionEntity tx) {
    if (tx.isTransfer) return 'Transfer';
    return tx.type == TransactionType.income ? 'Income' : 'Expense';
  }
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
