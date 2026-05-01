import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Replaces both the "expenses bar chart" and "income donut" with one
/// unified surface: a ranked list where each row shows category, amount,
/// percentage and a horizontal progress bar sized relative to the largest
/// entry. Easier to scan than vertical bars or donuts when you have more
/// than 3-4 categories.
class CategoryBreakdownList extends StatelessWidget {
  const CategoryBreakdownList({
    required this.data,
    required this.isExpense,
    this.onCategoryTap,
    super.key,
  });

  final List<CategoryAmount> data;
  final bool isExpense;
  final void Function(CategoryAmount)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.fold<double>(0, (s, e) => s + e.amount);
    final max = data.first.amount;

    return Column(
      children: [
        for (var i = 0; i < data.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                height: 0.5,
                color: context.appColors.surfaceVariant,
              ),
            ),
          _BreakdownRow(
            entry: data[i],
            total: total,
            maxAmount: max,
            isExpense: isExpense,
            onTap: onCategoryTap == null
                ? null
                : () => onCategoryTap!(data[i]),
          ),
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.entry,
    required this.total,
    required this.maxAmount,
    required this.isExpense,
    required this.onTap,
  });

  final CategoryAmount entry;
  final double total;
  final double maxAmount;
  final bool isExpense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = Color(entry.categoryColor);
    final percent = total == 0 ? 0.0 : (entry.amount / total) * 100;
    // Bar fills relative to the biggest entry, not the total — keeps the
    // visual difference readable even when the dataset is dominated by one
    // bucket (no microscopic 1px bars at the bottom).
    final barFraction = maxAmount == 0 ? 0.0 : entry.amount / maxAmount;
    final amountText = isExpense
        ? '-${formatCurrency(entry.amount)}'
        : formatCurrency(entry.amount);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.categoryName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.onBackgroundLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    amountText,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: isExpense ? colors.expense : colors.income,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 6),
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 10,
                      color: colors.onBackgroundLight,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: barFraction.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: colors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
