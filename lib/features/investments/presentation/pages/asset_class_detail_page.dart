import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/features/investments/presentation/cubit/investments_cubit.dart';
import 'package:financo/features/investments/presentation/pages/asset_class_form_page.dart';
import 'package:financo/features/investments/presentation/pages/asset_holding_sheet.dart';
import 'package:financo/features/investments/presentation/widgets/add_subclass_button.dart';
import 'package:financo/features/investments/presentation/widgets/asset_class_hero_card.dart';
import 'package:financo/features/investments/presentation/widgets/asset_subclass_card.dart';
import 'package:financo/features/investments/presentation/widgets/asset_subclass_empty_state.dart';
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
              failure: state.failure,
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
          AssetClassHeroCard(
            slice: slice,
            tint: tint,
            actualPercent: actualPercent,
            targetPercent: targetPercent,
          ),
          const SizedBox(height: 20),
          _SectionHeader(text: t.investments.detailSubclassesSection),
          const SizedBox(height: 8),
          if (slice.subclasses.isEmpty)
            AssetSubclassEmptyState(
              onAdd: () => unawaited(_addSubclass(context)),
            )
          else ...[
            for (final sub in slice.subclasses) ...[
              AssetSubclassCard(
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
            AddSubclassButton(
              onPressed: () => unawaited(_addSubclass(context)),
            ),
          ],
        ],
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
