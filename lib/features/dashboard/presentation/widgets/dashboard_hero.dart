import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Hero of the dashboard — the question users open this page to answer.
/// Top half: total balance (big number). Bottom half: month's income,
/// expenses and net result as inline chips so the user gets a snapshot
/// without scrolling.
class DashboardHero extends StatelessWidget {
  const DashboardHero({
    required this.totalBalance,
    required this.income,
    required this.expenses,
    required this.netResult,
    super.key,
  });

  final double totalBalance;
  final double income;
  final double expenses;
  final double netResult;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;

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
            t.dashboard.totalBalance.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(totalBalance),
            style: context.textTheme.displaySmall?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricChip(
                  icon: FontAwesomeIcons.arrowDown,
                  label: t.dashboard.income,
                  amount: income,
                  color: colors.income,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricChip(
                  icon: FontAwesomeIcons.arrowUp,
                  label: t.dashboard.expenses,
                  amount: expenses,
                  color: colors.expense,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricChip(
                  icon: netResult >= 0
                      ? FontAwesomeIcons.chartLine
                      : FontAwesomeIcons.triangleExclamation,
                  label: t.dashboard.netResult,
                  amount: netResult,
                  color: netResult >= 0 ? colors.income : colors.expense,
                  signed: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    this.signed = false,
  });

  final FaIconData icon;
  final String label;
  final double amount;
  final Color color;

  /// True for the net-result chip — prefixes with `+` when positive so the
  /// user sees the direction at a glance without doing the math.
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final formatted = signed && amount > 0
        ? '+${formatCurrency(amount)}'
        : formatCurrency(amount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 10, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onBackgroundLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatted,
              style: context.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
