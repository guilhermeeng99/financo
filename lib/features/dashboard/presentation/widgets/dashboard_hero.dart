import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Top-of-dashboard summary strip: month income, expenses, and net
/// result. The "total balance" number used to sit on top of these chips
/// but moved into the Account Balances section as a live total of the
/// selected checking accounts, so the user can mute accounts they don't
/// want counted (e.g. shared, joint, dormant).
class DashboardHero extends StatelessWidget {
  const DashboardHero({
    required this.income,
    required this.expenses,
    required this.netResult,
    super.key,
  });

  final double income;
  final double expenses;
  final double netResult;

  // Above this width the strip switches to a roomier 3-card layout that
  // suits web/tablet; below it we keep the original compact chip design
  // tuned for phone screens.
  static const double _wideBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isWide = context.screenSize.width >= _wideBreakpoint;

    final entries = <_HeroEntry>[
      _HeroEntry(
        icon: FontAwesomeIcons.arrowDown,
        label: t.dashboard.income,
        amount: income,
        accent: colors.income,
      ),
      _HeroEntry(
        icon: FontAwesomeIcons.arrowUp,
        label: t.dashboard.expenses,
        amount: expenses,
        accent: colors.expense,
      ),
      _HeroEntry(
        icon: netResult >= 0
            ? FontAwesomeIcons.chartLine
            : FontAwesomeIcons.triangleExclamation,
        label: t.dashboard.netResult,
        amount: netResult,
        accent: netResult >= 0 ? colors.income : colors.expense,
        signed: true,
      ),
    ];

    return isWide
        ? _WideLayout(entries: entries)
        : _CompactLayout(entries: entries);
  }
}

class _HeroEntry {
  const _HeroEntry({
    required this.icon,
    required this.label,
    required this.amount,
    required this.accent,
    this.signed = false,
  });

  final FaIconData icon;
  final String label;
  final double amount;
  final Color accent;
  final bool signed;
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({required this.entries});

  final List<_HeroEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Solid `surfaceVariant` in both themes — the light gradient
    // (`surface → primary @ 6%`) read as a violet wash that fought the
    // accent chips inside. The dark mode treatment was already a flat
    // surface, so we mirror it on light using the light palette's
    // surfaceVariant (the same token the dark side uses).
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _MetricChip(entry: entries[i])),
          ],
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.entries});

  final List<_HeroEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _MetricCard(entry: entries[i])),
        ],
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.entry});

  final _HeroEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final formatted = entry.signed && entry.amount > 0
        ? '+${formatCurrency(entry.amount)}'
        : formatCurrency(entry.amount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: entry.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(entry.icon, size: 10, color: entry.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entry.label,
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
                color: entry.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.entry});

  final _HeroEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    final formatted = entry.signed && entry.amount > 0
        ? '+${formatCurrency(entry.amount)}'
        : formatCurrency(entry.amount);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.onBackgroundLight.withValues(alpha: 0.10),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: entry.accent.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: entry.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(entry.icon, size: 12, color: entry.accent),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            entry.label,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatted,
              style: context.textTheme.titleMedium?.copyWith(
                color: entry.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
