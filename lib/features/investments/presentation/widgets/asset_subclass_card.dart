import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Row card for one subclass on the asset-class detail page: name,
/// current amount with share of class, an add/trim/balanced suggestion
/// against [suggestedTarget], and an inline Allocate chip. Tapping the
/// card itself fires [onEdit].
class AssetSubclassCard extends StatelessWidget {
  const AssetSubclassCard({
    required this.slice,
    required this.parentTint,
    required this.suggestedTarget,
    required this.onAllocate,
    required this.onEdit,
    super.key,
  });

  final InvestmentSubclassSlice slice;
  final Color parentTint;
  final double suggestedTarget;
  final VoidCallback onAllocate;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actualPercent = (slice.percentOfClass * 100).toStringAsFixed(0);
    final targetPercent = slice.targetPercent.toStringAsFixed(0);
    final hasTarget = slice.targetPercent > 0;
    final delta = suggestedTarget - slice.currentAmount;
    final isBelow = hasTarget && delta > 1;
    final isAbove = hasTarget && delta < -1;
    final suggestionColor = !hasTarget
        ? colors.onBackgroundLight
        : isBelow
            ? colors.warning
            : (isAbove ? colors.expense : colors.success);
    final suggestionLabel = !hasTarget
        ? t.investments.subclassSuggestionNoTarget
        : isBelow
            ? t.investments.subclassSuggestionAdd(
                amount: formatCurrency(delta),
              )
            : (isAbove
                ? t.investments.subclassSuggestionTrim(
                    amount: formatCurrency(delta.abs()),
                  )
                : t.investments.subclassSuggestionBalanced);
    // "16% of 30%" makes the gap between what this subclass holds and
    // what it should hold readable at a glance. Falls back to plain
    // share-of-class when no target has been set.
    final detailLine = hasTarget
        ? t.investments.subclassDetailLineTarget(
            amount: formatCurrency(slice.currentAmount),
            actual: '$actualPercent%',
            target: '$targetPercent%',
          )
        : t.investments.subclassDetailLine(
            amount: formatCurrency(slice.currentAmount),
            percent: '$actualPercent%',
          );
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        // The Allocate chip is its own InkWell — taps over it absorb
        // first and never reach this outer one. Anywhere else opens
        // the subclass edit form.
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 48,
                decoration: BoxDecoration(
                  color: parentTint.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
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
                      detailLine,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestionLabel,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: suggestionColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _AllocateChip(onTap: onAllocate),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact filled pill for the per-subclass "Allocate" action. Same
/// primary fill / 12px radius / 32px height as the project's other
/// inline actions (matches the chips used elsewhere by `FinancoSubmitBar`
/// at a smaller scale).
class _AllocateChip extends StatelessWidget {
  const _AllocateChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.plus,
                size: 11,
                color: colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                t.investments.allocateAction,
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
