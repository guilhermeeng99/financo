import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Pre-computed totals over the user's pending bills. Built in the page
/// (cheap — list is already cached locally) so the bloc stays UI-agnostic.
class BillsSummary {
  const BillsSummary({
    required this.totalToPay,
    required this.totalToReceive,
    required this.pendingCount,
    required this.overdueCount,
    required this.overdueAmount,
  });

  factory BillsSummary.from(List<BillEntity> bills) {
    var pay = 0.0;
    var receive = 0.0;
    var pending = 0;
    var overdueCount = 0;
    var overdueAmount = 0.0;
    for (final b in bills) {
      if (!b.isPending) continue;
      pending++;
      if (b.isPayable) pay += b.amount;
      if (b.isReceivable) receive += b.amount;
      if (b.isOverdue) {
        overdueCount++;
        overdueAmount += b.amount;
      }
    }
    return BillsSummary(
      totalToPay: pay,
      totalToReceive: receive,
      pendingCount: pending,
      overdueCount: overdueCount,
      overdueAmount: overdueAmount,
    );
  }

  final double totalToPay;
  final double totalToReceive;
  final int pendingCount;
  final int overdueCount;
  final double overdueAmount;

  bool get isEmpty => pendingCount == 0;
  bool get hasOverdue => overdueCount > 0;
  bool get hasReceivable => totalToReceive > 0;
}

/// Hero card on the Bills page. Surfaces the total a user is on the hook for
/// this period — the question users open this screen to answer.
class BillsSummaryCard extends StatelessWidget {
  const BillsSummaryCard({required this.summary, super.key});

  final BillsSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;

    // Light mode: subtle gradient lifts the card off the gray background
    // without resorting to shadow. Dark mode: solid surfaceVariant gives the
    // same effect by being one step lighter than the scaffold.
    final decoration = isDark
        ? BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surface,
                colors.primary.withValues(alpha: 0.06),
              ],
            ),
          );

    return Container(
      decoration: decoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.bills.summaryTitle.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          if (summary.isEmpty)
            _EmptyTotal(message: t.bills.summaryAllCaughtUp)
          else ...[
            _PrimaryAmount(
              label: t.bills.typePayable,
              amount: summary.totalToPay,
              color: colors.onBackground,
            ),
            const SizedBox(height: 4),
            Text(
              t.bills.pendingCount(count: summary.pendingCount),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
            if (summary.hasOverdue) ...[
              const SizedBox(height: 16),
              _OverdueChip(
                count: summary.overdueCount,
                amount: summary.overdueAmount,
              ),
            ],
            if (summary.hasReceivable) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _SecondaryRow(
                label: t.bills.typeReceivable,
                amount: summary.totalToReceive,
                color: colors.income,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PrimaryAmount extends StatelessWidget {
  const _PrimaryAmount({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatCurrency(amount),
          style: context.textTheme.displaySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SecondaryRow extends StatelessWidget {
  const _SecondaryRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
        Text(
          formatCurrency(amount),
          style: context.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OverdueChip extends StatelessWidget {
  const _OverdueChip({required this.count, required this.amount});

  final int count;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.expense.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: 12,
            color: colors.expense,
          ),
          const SizedBox(width: 8),
          Text(
            t.bills.overdueChip(count: count),
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.expense,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' · ${formatCurrency(amount)}',
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.expense,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTotal extends StatelessWidget {
  const _EmptyTotal({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.circleCheck,
          size: 22,
          color: colors.success,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
