import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/features/investments/presentation/cubit/investments_cubit.dart';
import 'package:financo/features/investments/presentation/pages/asset_class_form_page.dart';
import 'package:financo/features/investments/presentation/pages/asset_holding_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Detail view for a single root class. Surfaces the subclass-level
/// breakdown the overview intentionally hides — current amount, share
/// of class, and a suggested "ideal" amount per subclass derived from
/// an equal split of the class's own target. The user reaches this
/// page by tapping a class row on `InvestmentsPage`; the edit icon
/// in the app bar opens the class form.
class AssetClassDetailPage extends StatelessWidget {
  const AssetClassDetailPage({required this.classId, super.key});

  final String classId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestmentsCubit, InvestmentsState>(
      builder: (context, state) {
        final colors = context.appColors;
        if (state is InvestmentsLoading || state is InvestmentsInitial) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: FinancoLargeAppBar(
              title: t.investments.classDetailTitle,
              showBack: true,
            ),
            body: const LoadingShimmer(),
          );
        }
        if (state is InvestmentsError) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: FinancoLargeAppBar(
              title: t.investments.classDetailTitle,
              showBack: true,
            ),
            body: ErrorView(
              message: state.failure.message,
              onRetry: () => unawaited(
                context.read<InvestmentsCubit>().refresh(forceRefresh: true),
              ),
            ),
          );
        }
        state as InvestmentsLoaded;
        final slice = state.overview.classBreakdown
            .where((c) => c.classId == classId)
            .cast<InvestmentClassSlice?>()
            .firstWhere((c) => true, orElse: () => null);
        if (slice == null) {
          // Class was deleted (e.g. from another tab) — bounce back
          // to the overview rather than crash.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.pop();
          });
          return Scaffold(
            backgroundColor: colors.background,
            appBar: FinancoLargeAppBar(
              title: t.investments.classDetailTitle,
              showBack: true,
            ),
            body: const SizedBox.shrink(),
          );
        }
        final entity =
            state.classes.firstWhere((c) => c.id == classId);
        return _DetailView(slice: slice, classEntity: entity, state: state);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.slice,
    required this.classEntity,
    required this.state,
  });

  final InvestmentClassSlice slice;
  final AssetClassEntity classEntity;
  final InvestmentsLoaded state;

  Future<void> _openEdit(BuildContext context) async {
    final result = await context.push(
      AppRoutes.assetClass,
      extra: AssetClassFormArgs(existing: classEntity),
    );
    if (result == true && context.mounted) {
      unawaited(
        context.read<InvestmentsCubit>().refresh(forceRefresh: true),
      );
    }
  }

  Future<void> _addSubclass(BuildContext context) async {
    final result = await context.push(
      AppRoutes.assetClass,
      extra: AssetClassFormArgs(presetParent: classEntity),
    );
    if (result == true && context.mounted) {
      unawaited(
        context.read<InvestmentsCubit>().refresh(forceRefresh: true),
      );
    }
  }

  Future<void> _editSubclass(BuildContext context, String subclassId) async {
    final subEntity = state.classes.cast<AssetClassEntity?>().firstWhere(
      (c) => c?.id == subclassId,
      orElse: () => null,
    );
    if (subEntity == null) return;
    final result = await context.push(
      AppRoutes.assetClass,
      extra: AssetClassFormArgs(existing: subEntity),
    );
    if (result == true && context.mounted) {
      unawaited(
        context.read<InvestmentsCubit>().refresh(forceRefresh: true),
      );
    }
  }

  Future<void> _openHoldingSheet(
    BuildContext context,
    String subclassId,
  ) async {
    final investmentAccounts = state.accounts
        .where((a) => a.type == AccountType.investment)
        .toList();
    final saved = await showAssetHoldingSheet(
      context: context,
      investmentAccounts: investmentAccounts,
      classes: state.classes,
      holdings: state.holdings,
      presetClassId: subclassId,
    );
    if (saved == true && context.mounted) {
      unawaited(
        context.read<InvestmentsCubit>().refresh(forceRefresh: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = Color(slice.color);
    final actualPercent = (slice.currentPercent * 100).toStringAsFixed(0);
    final targetPercent = slice.targetPercent.toStringAsFixed(0);

    // Per-subclass suggested target uses the user-declared
    // `targetPercent` (share of the parent class). When the user
    // hasn't set any sub-targets yet, every subclass reads 0% and
    // the suggestion collapses to "no opinion".
    double suggestedFor(InvestmentSubclassSlice sub) {
      final pct = sub.targetPercent;
      if (pct <= 0) return 0;
      return slice.targetAmount * (pct / 100);
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: FinancoLargeAppBar(
        title: slice.name,
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 4),
            child: _EditChip(onTap: () => unawaited(_openEdit(context))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          _HeroCard(
            slice: slice,
            tint: tint,
            actualPercent: actualPercent,
            targetPercent: targetPercent,
          ),
          const SizedBox(height: 20),
          _SectionHeader(text: t.investments.detailSubclassesSection),
          const SizedBox(height: 8),
          if (slice.subclasses.isEmpty)
            _NoSubclasses(
              onAdd: () => unawaited(_addSubclass(context)),
            )
          else ...[
            for (final sub in slice.subclasses) ...[
              _SubclassCard(
                slice: sub,
                parentTint: tint,
                suggestedTarget: suggestedFor(sub),
                onAllocate: () => unawaited(
                  _openHoldingSheet(context, sub.subclassId),
                ),
                onEdit: () => unawaited(
                  _editSubclass(context, sub.subclassId),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            _AddSubclassButton(
              onPressed: () => unawaited(_addSubclass(context)),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.slice,
    required this.tint,
    required this.actualPercent,
    required this.targetPercent,
  });

  final InvestmentClassSlice slice;
  final Color tint;
  final String actualPercent;
  final String targetPercent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final deltaColor = slice.deltaAmount.abs() < 1
        ? colors.success
        : (slice.isUnderTarget ? colors.warning : colors.expense);
    final deltaLabel = slice.deltaAmount.abs() < 1
        ? t.investments.classRowOnTarget
        : (slice.isUnderTarget
            ? t.investments.classRowUnderTarget(
                amount: formatCurrency(slice.deltaAmount.abs()),
              )
            : t.investments.classRowOverTarget(
                amount: formatCurrency(slice.deltaAmount.abs()),
              ));
    final targetFraction = slice.targetPercent / 100;
    final progress = targetFraction <= 0
        ? slice.currentPercent.clamp(0.0, 1.0)
        : (slice.currentPercent / targetFraction).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    materialIconFor(slice.icon),
                    size: 22,
                    color: tint,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCurrency(slice.currentAmount),
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
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
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(tint),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.investments.detailTargetAmount(
                  amount: formatCurrency(slice.targetAmount),
                ),
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onBackgroundLight,
                ),
              ),
              Text(
                deltaLabel,
                style: context.textTheme.bodySmall?.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubclassCard extends StatelessWidget {
  const _SubclassCard({
    required this.slice,
    required this.parentTint,
    required this.suggestedTarget,
    required this.onAllocate,
    required this.onEdit,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors.onBackgroundLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSubclasses extends StatelessWidget {
  const _NoSubclasses({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.layerGroup,
            size: 24,
            color: colors.onBackgroundLight,
          ),
          const SizedBox(height: 12),
          Text(
            t.investments.detailNoSubclassesTitle,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.investments.detailNoSubclassesBody,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
          const SizedBox(height: 16),
          _AddSubclassButton(onPressed: onAdd),
        ],
      ),
    );
  }
}

/// Circular pill housing the "edit class" pencil in the app bar.
/// Matches the look of the `_BackChip` shipped with
/// `FinancoLargeAppBar`: 36×36 surface-variant circle with a primary
/// glyph. Replaces the unstyled `IconButton` which read as flat /
/// detached from the rest of the bar.
class _EditChip extends StatelessWidget {
  const _EditChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceVariant,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: t.investments.editClassTitle,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.penToSquare,
                size: 14,
                color: colors.primary,
              ),
            ),
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

/// Full-width primary action used by both the "no subclasses" empty
/// state and the trailing CTA under the subclass list. Mirrors the
/// dimensions of `FinancoSubmitBar` (52 high, 14px radius, primary
/// fill, white text) so it reads as a real submit and not a
/// decoration.
class _AddSubclassButton extends StatelessWidget {
  const _AddSubclassButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
        label: Text(
          t.investments.addSubclass,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
