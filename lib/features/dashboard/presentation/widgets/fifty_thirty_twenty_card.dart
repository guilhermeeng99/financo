import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Dashboard card that surfaces the 50/30/20 rule for the active period.
///
/// Reads from `DashboardSummary.fiftyThirtyTwenty` (computed inside
/// `DashboardRepositoryImpl`). The card has three layouts driven by
/// `overview.status`:
///
/// - `noData`: collapsed empty hint asking the user to log income.
/// - any other state: full layout with three bucket rows + footer
///   advice line.
///
/// See `specs/fifty_thirty_twenty.md` §6 for design rationale.
class FiftyThirtyTwentyCard extends StatelessWidget {
  const FiftyThirtyTwentyCard({required this.overview, super.key});

  final FiftyThirtyTwentyOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Display-only — detail page is reachable via the shell nav (sidebar
    // on desktop, bottom bar on mobile), so a redundant card-tap target
    // was removed. Footer CTA chips still capture their own taps for
    // category / account flows.
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: overview.hasData
          ? _FullLayout(overview: overview)
          : _EmptyLayout(overview: overview),
    );
  }
}

/// "Log income to see this" — single-line empty state.
class _EmptyLayout extends StatelessWidget {
  const _EmptyLayout({required this.overview});

  final FiftyThirtyTwentyOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.chartPie,
                  size: 14,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.fiftyThirtyTwenty.noIncomeHeadline,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onBackground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Three bucket rows + headline + footer advice.
class _FullLayout extends StatelessWidget {
  const _FullLayout({required this.overview});

  final FiftyThirtyTwentyOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardHeader(income: overview.income),
        const SizedBox(height: 14),
        _BucketRow(
          label: t.fiftyThirtyTwenty.needsLabel,
          icon: FontAwesomeIcons.house,
          baseColor: colors.primary,
          actualPercent: overview.needsPercent,
          targetPercent: 0.5,
          actualAmount: overview.needsSpent,
          targetAmount: overview.needsTarget,
          isUnder: false,
        ),
        const SizedBox(height: 12),
        _BucketRow(
          label: t.fiftyThirtyTwenty.wantsLabel,
          icon: FontAwesomeIcons.heart,
          baseColor: colors.warning,
          actualPercent: overview.wantsPercent,
          targetPercent: 0.3,
          actualAmount: overview.wantsSpent,
          targetAmount: overview.wantsTarget,
          isUnder: false,
        ),
        const SizedBox(height: 12),
        _BucketRow(
          label: t.fiftyThirtyTwenty.savingsLabel,
          icon: FontAwesomeIcons.piggyBank,
          baseColor: colors.income,
          actualPercent: overview.savingsPercent,
          targetPercent: 0.2,
          actualAmount: overview.savingsAmount,
          targetAmount: overview.savingsTarget,
          // Savings is the only bucket where "under" is the bad state.
          // The row flips the bar fill semantics: we render
          // `actual / target` so a full bar means "hit the goal" rather
          // than "spent everything".
          isUnder: true,
        ),
        const SizedBox(height: 14),
        _FooterAdvice(overview: overview),
      ],
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({this.income});

  /// Period income that backs the 100% baseline. Null hides the trailing
  /// pill — used by the empty layout where there's nothing to anchor
  /// against.
  final double? income;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          t.fiftyThirtyTwenty.title.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        if (income != null && income! > 0) ...[
          const SizedBox(width: 8),
          _BaselinePill(income: income!),
        ],
      ],
    );
  }
}

/// Compact "100% = R$ X" chip shown on the right of the header so the
/// user can read the absolute baseline that the bar percentages are
/// measured against.
class _BaselinePill extends StatelessWidget {
  const _BaselinePill({required this.income});

  final double income;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.income.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        t.fiftyThirtyTwenty.baselinePill(value: formatCurrency(income)),
        style: context.textTheme.labelSmall?.copyWith(
          color: colors.income,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Single bucket row: icon · label · bar · percentages · amount.
class _BucketRow extends StatelessWidget {
  const _BucketRow({
    required this.label,
    required this.icon,
    required this.baseColor,
    required this.actualPercent,
    required this.targetPercent,
    required this.actualAmount,
    required this.targetAmount,
    required this.isUnder,
  });

  final String label;
  final FaIconData icon;
  final Color baseColor;
  final double actualPercent;
  final double targetPercent;
  final double actualAmount;
  final double targetAmount;
  final bool isUnder;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // For needs/wants the bar represents actual against the full income —
    // visually capped at 1.0 with the target marker drawn at its slot.
    // For savings, the bar represents "how close to the target you are":
    // value = actual / target, so the bar reaches the right edge exactly
    // when you hit 20%.
    final progress = isUnder
        ? (targetPercent == 0 ? 0.0 : (actualPercent / targetPercent))
        : actualPercent;
    final clampedProgress = progress.clamp(0.0, 1.0);

    final isOff = _isOff(actualPercent, targetPercent, isUnder: isUnder);
    final barColor = isOff
        ? (isUnder ? colors.warning : colors.expense)
        : baseColor;

    final headerLabel = '$label · ${formatCurrency(actualAmount)}';
    final percentLabel = t.fiftyThirtyTwenty.ofTarget(
      actual: (actualPercent * 100).round(),
      target: (targetPercent * 100).round(),
    );

    return Semantics(
      label: '$headerLabel · $percentLabel',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 12, color: baseColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headerLabel,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                percentLabel,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isOff ? barColor : colors.onBackgroundLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _BarWithMarker(
            progress: clampedProgress,
            barColor: barColor,
            // Target marker only meaningful when the bar represents the
            // full-income axis (i.e. not the savings normalized bar).
            markerAt: isUnder ? null : targetPercent,
          ),
        ],
      ),
    );
  }

  bool _isOff(double actual, double target, {required bool isUnder}) {
    if (isUnder) return actual < target;
    return actual > target;
  }
}

/// Linear bar with an optional vertical marker indicating the target.
/// Hand-painted so we can render the marker as a thin vertical line
/// without re-implementing the whole progress widget.
class _BarWithMarker extends StatelessWidget {
  const _BarWithMarker({
    required this.progress,
    required this.barColor,
    required this.markerAt,
  });

  final double progress;
  final Color barColor;
  final double? markerAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: width,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),
              if (markerAt != null)
                Positioned(
                  left: (width * markerAt!.clamp(0.0, 1.0)) - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: colors.onBackground.withValues(alpha: 0.45),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One-liner under the bars summarising the most actionable next step
/// for the user. Order of precedence is intentional — `unclassified`
/// trumps everything because the numbers are untrustworthy without it.
class _FooterAdvice extends StatelessWidget {
  const _FooterAdvice({required this.overview});

  final FiftyThirtyTwentyOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final advice = _resolveAdvice(context);
    if (advice == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          FaIcon(
            advice.icon,
            size: 11,
            color: colors.onBackgroundLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice.text,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (advice.ctaLabel != null && advice.onCtaTap != null) ...[
            const SizedBox(width: 8),
            _CtaChip(label: advice.ctaLabel!, onTap: advice.onCtaTap!),
          ],
        ],
      ),
    );
  }

  _Advice? _resolveAdvice(BuildContext context) {
    if (overview.hasUnclassified &&
        overview.status == FiftyThirtyTwentyStatus.unclassifiedDominant) {
      return _Advice(
        text: t.fiftyThirtyTwenty.tipUnclassified(
          count: overview.unclassifiedCount,
        ),
        icon: FontAwesomeIcons.tag,
        ctaLabel: t.fiftyThirtyTwenty.ctaClassify,
        onCtaTap: () => context.go(AppRoutes.categories),
      );
    }
    if (overview.needsStatus == BucketStatus.over) {
      return _Advice(
        text: t.fiftyThirtyTwenty.tipNeedsOver(
          value: formatCurrency(overview.needsOverflow),
        ),
        icon: FontAwesomeIcons.scaleUnbalanced,
      );
    }
    if (overview.wantsStatus == BucketStatus.over) {
      return _Advice(
        text: t.fiftyThirtyTwenty.tipWantsOver(
          value: formatCurrency(overview.wantsOverflow),
        ),
        icon: FontAwesomeIcons.cartShopping,
      );
    }
    if (overview.savingsStatus == BucketStatus.under) {
      if (overview.hasInvestmentAccount) {
        return _Advice(
          text: t.fiftyThirtyTwenty.tipSavingsShortWithAccount(
            value: formatCurrency(overview.savingsShortfall),
          ),
          icon: FontAwesomeIcons.piggyBank,
        );
      }
      return _Advice(
        text: t.fiftyThirtyTwenty.tipSavingsShortNoAccount,
        icon: FontAwesomeIcons.piggyBank,
        ctaLabel: t.fiftyThirtyTwenty.ctaCreateInvestment,
        onCtaTap: () => context.push(AppRoutes.addAccount),
      );
    }
    if (overview.hasUnclassified) {
      return _Advice(
        text: t.fiftyThirtyTwenty.tipUnclassified(
          count: overview.unclassifiedCount,
        ),
        icon: FontAwesomeIcons.tag,
        ctaLabel: t.fiftyThirtyTwenty.ctaClassify,
        onCtaTap: () => context.go(AppRoutes.categories),
      );
    }
    return null;
  }
}

class _Advice {
  _Advice({
    required this.text,
    required this.icon,
    this.ctaLabel,
    this.onCtaTap,
  });

  final String text;
  final FaIconData icon;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;
}

class _CtaChip extends StatelessWidget {
  const _CtaChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kept exported so widget tests can drive the same colour resolution
/// the production card uses, without re-implementing the switch.
Color resolveBucketStatusColor(
  AppColorsData colors,
  BucketStatus status, {
  required Color baseColor,
}) {
  return switch (status) {
    BucketStatus.onTrack => baseColor,
    BucketStatus.over => colors.expense,
    BucketStatus.under => colors.warning,
  };
}
