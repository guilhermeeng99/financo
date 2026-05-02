import 'dart:async';

import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/budgets/domain/entities/budget_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Single row in the budgets list. Shows the category icon, the spent /
/// cap pair, percentage used, and a horizontal progress bar coloured by
/// the budget's status (safe / warning / exceeded).
class BudgetTile extends StatelessWidget {
  const BudgetTile({
    required this.overview,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final BudgetOverview overview;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color _statusColor(AppColorsData colors) {
    return switch (overview.status) {
      BudgetStatus.safe => colors.success,
      BudgetStatus.warning => colors.warning,
      BudgetStatus.exceeded => colors.expense,
    };
  }

  String _statusLabel() {
    return switch (overview.status) {
      BudgetStatus.safe => t.budgets.statusSafe,
      BudgetStatus.warning => t.budgets.statusWarning,
      BudgetStatus.exceeded => t.budgets.statusExceeded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final categoryColor = Color(overview.categoryColor);
    final statusColor = _statusColor(colors);
    // Clamp at 1.0 so the bar visually maxes out — the textual % still
    // shows the uncapped value, so an overspend of 120% reads "120%" but
    // the bar stops at the right edge.
    final progress = overview.percentage.clamp(0.0, 1.0);
    final percentageLabel =
        '${(overview.percentage * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _IconDisc(
                        iconCode: overview.categoryIcon,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              overview.categoryName,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: colors.onBackground,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.budgets.spentOf(
                                spent: formatCurrency(overview.spent),
                                cap: formatCurrency(overview.budget.amount),
                              ),
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
                      _StatusChip(
                        label: '$percentageLabel · ${_statusLabel()}',
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      _DeleteButton(onPressed: onDelete),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: colors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    overview.status == BudgetStatus.exceeded
                        ? t.budgets.overBy(
                            value: formatCurrency(overview.overspent),
                          )
                        : t.budgets.remainingOf(
                            value: formatCurrency(overview.remaining),
                          ),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: overview.status == BudgetStatus.exceeded
                          ? colors.expense
                          : colors.onBackgroundLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.iconCode, required this.color});

  final int iconCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          IconData(iconCode, fontFamily: 'MaterialIcons'),
          size: 18,
          color: color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onPressed();
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.trash,
              size: 12,
              color: colors.onBackgroundLight,
            ),
          ),
        ),
      ),
    );
  }
}
