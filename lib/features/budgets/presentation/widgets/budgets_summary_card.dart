import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class BudgetsSummaryCard extends StatelessWidget {
  const BudgetsSummaryCard({
    required this.totalCap,
    required this.totalSpent,
    required this.totalRemaining,
    super.key,
  });

  final double totalCap;
  final double totalSpent;
  final double totalRemaining;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.budgets.summaryTitle,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Cell(
                  label: t.budgets.summaryCap,
                  value: formatCurrency(totalCap),
                  color: colors.onBackground,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: colors.surfaceVariant,
              ),
              Expanded(
                child: _Cell(
                  label: t.budgets.summarySpent,
                  value: formatCurrency(totalSpent),
                  color: colors.expense,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: colors.surfaceVariant,
              ),
              Expanded(
                child: _Cell(
                  label: t.budgets.summaryRemaining,
                  value: formatCurrency(totalRemaining),
                  color: colors.income,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
