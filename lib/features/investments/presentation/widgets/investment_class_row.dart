import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Summary tile for a single root class on the Investments overview.
/// Tapping it pushes the dedicated detail page (subclass breakdown +
/// per-subclass suggestions). This widget intentionally hides the
/// subclass list — the overview shows only class-level status so the
/// page reads as a snapshot, not a drill-down.
class InvestmentClassRow extends StatelessWidget {
  const InvestmentClassRow({
    required this.slice,
    required this.onTap,
    super.key,
  });

  final InvestmentClassSlice slice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = Color(slice.color);
    final deltaColor = _deltaColor(context);
    final deltaLabel = _deltaLabel();
    final progress = _progressValue();
    final actualPercent = (slice.currentPercent * 100).toStringAsFixed(0);
    final targetPercent = slice.targetPercent.toStringAsFixed(0);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RootAvatar(icon: slice.icon, tint: tint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slice.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.investments.classRowSubtitle(
                            actual: '$actualPercent%',
                            target: '$targetPercent%',
                          ),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onBackgroundLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(slice.currentAmount),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deltaLabel,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: deltaColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 11,
                    color: colors.onBackgroundLight,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(tint),
                ),
              ),
              if (slice.subclasses.isEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  t.investments.classRowNoSubclasses,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onBackgroundLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Bar maps `currentPercent` against the denominator that makes
  /// "on-target" read as a full bar. When the user is under target the
  /// bar fills proportionally; once they exceed it, the bar caps at
  /// 100% and the textual delta carries the magnitude.
  double _progressValue() {
    final targetFraction = slice.targetPercent / 100;
    if (targetFraction <= 0) return slice.currentPercent.clamp(0.0, 1.0);
    final ratio = slice.currentPercent / targetFraction;
    return ratio.clamp(0.0, 1.0);
  }

  String _deltaLabel() {
    if (slice.deltaAmount.abs() < 1) return t.investments.classRowOnTarget;
    final amount = formatCurrency(slice.deltaAmount.abs());
    return slice.isUnderTarget
        ? t.investments.classRowUnderTarget(amount: amount)
        : t.investments.classRowOverTarget(amount: amount);
  }

  Color _deltaColor(BuildContext context) {
    final colors = context.appColors;
    if (slice.deltaAmount.abs() < 1) return colors.success;
    return slice.isUnderTarget ? colors.warning : colors.expense;
  }
}

class _RootAvatar extends StatelessWidget {
  const _RootAvatar({required this.icon, required this.tint});

  final int icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        // Same `MaterialIcons` family the category picker stores —
        // see `FinancoCategoryAvatar`. Avoids glyph-table mismatch
        // against FontAwesome's font.
        child: Icon(
          materialIconFor(icon),
          size: 18,
          color: tint,
        ),
      ),
    );
  }
}
