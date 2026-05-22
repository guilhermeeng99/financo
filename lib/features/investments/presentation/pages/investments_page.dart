import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_section_header.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';
import 'package:financo/features/investments/presentation/cubit/investments_cubit.dart';
import 'package:financo/features/investments/presentation/pages/asset_class_form_page.dart';
import 'package:financo/features/investments/presentation/pages/asset_holding_sheet.dart';
import 'package:financo/features/investments/presentation/widgets/investment_account_pending_row.dart';
import 'package:financo/features/investments/presentation/widgets/investment_allocation_donut.dart';
import 'package:financo/features/investments/presentation/widgets/investment_class_row.dart';
import 'package:financo/features/investments/presentation/widgets/investment_hero_card.dart';
import 'package:financo/features/investments/presentation/widgets/investment_pending_banner.dart';
import 'package:financo/features/investments/presentation/widgets/investment_rebalance_row.dart';
import 'package:financo/features/investments/presentation/widgets/investments_empty_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({super.key});

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  /// Renders the shimmer until the first page-initiated refresh
  /// resolves. Necessary because the shell-level cubit pre-load may
  /// have already emitted `Loaded({empty})` from a cold local cache,
  /// which would otherwise paint the empty state for a frame before
  /// the real Firestore read returns.
  bool _initialFetchPending = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInitial());
  }

  Future<void> _loadInitial() async {
    // Always force-refresh on mount — the cubit may already have a
    // snapshot from another page (e.g. dashboard banner read), but
    // the page itself wants the freshest read across accounts +
    // classes + holdings to avoid stale displays after an aporte.
    await context.read<InvestmentsCubit>().refresh(forceRefresh: true);
    if (mounted) setState(() => _initialFetchPending = false);
  }

  Future<void> _openClassForm({
    AssetClassEntity? existing,
    AssetClassEntity? presetParent,
  }) async {
    final result = await context.push(
      AppRoutes.assetClass,
      extra: AssetClassFormArgs(
        existing: existing,
        presetParent: presetParent,
      ),
    );
    if (result == true && mounted) {
      unawaited(
        context.read<InvestmentsCubit>().refresh(forceRefresh: true),
      );
    }
  }

  Future<void> _openClassDetail(String classId) async {
    final result =
        await context.push(AppRoutes.assetClassDetailById(classId));
    if (result == true && mounted) {
      unawaited(
        context.read<InvestmentsCubit>().refresh(forceRefresh: true),
      );
    }
  }

  Future<void> _openHoldingSheet({
    required InvestmentsLoaded loaded,
    AssetHoldingEntity? existing,
    String? presetAccountId,
    String? presetClassId,
  }) async {
    final investmentAccounts = loaded.accounts
        .where((a) => a.type == AccountType.investment)
        .toList();
    final saved = await showAssetHoldingSheet(
      context: context,
      investmentAccounts: investmentAccounts,
      classes: loaded.classes,
      holdings: loaded.holdings,
      existing: existing,
      presetAccountId: presetAccountId,
      presetClassId: presetClassId,
    );
    if (saved == true && mounted) {
      unawaited(
        context.read<InvestmentsCubit>().refresh(forceRefresh: true),
      );
    }
  }

  Future<void> _openAddSheet(InvestmentsLoaded loaded) async {
    final investmentAccounts = loaded.accounts
        .where((a) => a.type == AccountType.investment)
        .toList();
    final colors = context.appColors;
    final pick = await showModalBottomSheet<_AddChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onBackgroundLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              _AddChoiceTile(
                icon: FontAwesomeIcons.layerGroup,
                label: t.investments.fabAddClass,
                subtitle: t.investments.fabAddClassSubtitle,
                onTap: () =>
                    Navigator.of(sheetContext).pop(_AddChoice.assetClass),
              ),
              const SizedBox(height: 8),
              _AddChoiceTile(
                icon: FontAwesomeIcons.coins,
                label: t.investments.fabAddHolding,
                subtitle: t.investments.fabAddHoldingSubtitle,
                // Allocation needs an investment account AND at least
                // one subclass — root classes are organisational only,
                // so a portfolio of bare roots can't host holdings.
                enabled: investmentAccounts.isNotEmpty &&
                    loaded.classes.any((c) => c.parentId != null),
                disabledHint: investmentAccounts.isEmpty
                    ? t.investments.fabAddHoldingNoAccount
                    : t.investments.fabAddHoldingNoSubclass,
                onTap: () => Navigator.of(sheetContext).pop(_AddChoice.holding),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
    if (pick == null || !mounted) return;
    if (pick == _AddChoice.assetClass) {
      await _openClassForm();
    } else {
      await _openHoldingSheet(loaded: loaded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: FinancoLargeAppBar(title: t.investments.title),
      body: BlocBuilder<InvestmentsCubit, InvestmentsState>(
        builder: (context, state) {
          if (_initialFetchPending ||
              state is InvestmentsLoading ||
              state is InvestmentsInitial) {
            return const LoadingShimmer();
          }
          if (state is InvestmentsError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () => unawaited(
                context.read<InvestmentsCubit>().refresh(forceRefresh: true),
              ),
            );
          }
          state as InvestmentsLoaded;
          return _LoadedBody(
            state: state,
            onOpenClassForm: _openClassForm,
            onOpenClassDetail: _openClassDetail,
            onOpenHoldingSheet: _openHoldingSheet,
          );
        },
      ),
      floatingActionButton:
          BlocBuilder<InvestmentsCubit, InvestmentsState>(
        builder: (context, state) {
          if (_initialFetchPending || state is! InvestmentsLoaded) {
            return const SizedBox.shrink();
          }
          return LiftedFab(
            child: FloatingActionButton(
              heroTag: 'investments_fab',
              onPressed: () => unawaited(_openAddSheet(state)),
              child: const FaIcon(FontAwesomeIcons.plus),
            ),
          );
        },
      ),
    );
  }
}

enum _AddChoice { assetClass, holding }

class _AddChoiceTile extends StatelessWidget {
  const _AddChoiceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.disabledHint,
  });

  final FaIconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      size: 16,
                      color: enabled
                          ? colors.primary
                          : colors.onBackgroundLight,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: enabled
                              ? colors.onBackground
                              : colors.onBackgroundLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enabled
                            ? subtitle
                            : (disabledHint ?? subtitle),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.state,
    required this.onOpenClassForm,
    required this.onOpenClassDetail,
    required this.onOpenHoldingSheet,
  });

  final InvestmentsLoaded state;
  final Future<void> Function({
    AssetClassEntity? existing,
    AssetClassEntity? presetParent,
  }) onOpenClassForm;
  final Future<void> Function(String classId) onOpenClassDetail;
  final Future<void> Function({
    required InvestmentsLoaded loaded,
    AssetHoldingEntity? existing,
    String? presetAccountId,
    String? presetClassId,
  }) onOpenHoldingSheet;

  bool get _hasInvestmentAccounts => state.accounts.any(
        (a) => a.type == AccountType.investment,
      );

  @override
  Widget build(BuildContext context) {
    final overview = state.overview;
    final colors = context.appColors;

    if (!_hasInvestmentAccounts) {
      return InvestmentsEmptyState(
        icon: FontAwesomeIcons.piggyBank,
        title: t.investments.emptyNoAccountTitle,
        body: t.investments.emptyNoAccountMessage,
        example: t.investments.emptyNoAccountExample,
        actionLabel: t.investments.emptyNoAccountAction,
        onAction: () async {
          await context.push(AppRoutes.addAccount);
          if (context.mounted) {
            unawaited(
              context.read<AccountsCubit>().loadAccounts(forceRefresh: true),
            );
            unawaited(
              context
                  .read<InvestmentsCubit>()
                  .refresh(forceRefresh: true),
            );
          }
        },
      );
    }

    if (state.classes.isEmpty) {
      return InvestmentsEmptyState(
        icon: FontAwesomeIcons.layerGroup,
        title: t.investments.emptyNoClassesTitle,
        body: t.investments.emptyNoClassesMessage,
        example: t.investments.emptyNoClassesExample,
        actionLabel: t.investments.emptyNoClassesAction,
        onAction: () => unawaited(onOpenClassForm()),
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: () =>
          context.read<InvestmentsCubit>().refresh(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          InvestmentHeroCard(
            totalInvested: overview.totalInvested,
            totalAllocated: overview.totalAllocated,
            totalPending: overview.totalPending,
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0, duration: 300.ms),
          if (overview.hasPending) ...[
            const SizedBox(height: 14),
            InvestmentPendingBanner(
              totalPending: overview.totalPending,
              onTap: () => onOpenHoldingSheet(loaded: state),
            ),
          ],
          if (!overview.targetsBalanced) ...[
            const SizedBox(height: 14),
            _TargetsBanner(sum: overview.targetSumPercent),
          ],
          const SizedBox(height: 24),
          FinancoSectionHeader(title: t.investments.sectionAllocation),
          const SizedBox(height: 12),
          if (overview.hasInvestments)
            Center(
              child: InvestmentAllocationDonut(
                slices: overview.classBreakdown,
                totalInvested: overview.totalInvested,
              ),
            )
          else
            _DonutPlaceholder(
              text: t.investments.allocationEmpty,
            ),
          const SizedBox(height: 24),
          FinancoSectionHeader(title: t.investments.sectionClasses),
          const SizedBox(height: 8),
          ...overview.classBreakdown.map((slice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InvestmentClassRow(
                slice: slice,
                onTap: () => unawaited(onOpenClassDetail(slice.classId)),
              ),
            );
          }),
          if (overview.rebalanceActions.isNotEmpty) ...[
            const SizedBox(height: 12),
            FinancoSectionHeader(title: t.investments.sectionRebalance),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (overview.hasPending) ...[
                    Text(
                      t.investments.rebalanceAllocatePending(
                        amount: formatCurrency(overview.totalPending),
                      ),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  ...overview.rebalanceActions
                      .map((a) => InvestmentRebalanceRow(action: a)),
                ],
              ),
            ),
          ],
          if (overview.accountBreakdown.any(
            (s) => s.pending > 0 || s.hasOverflow,
          )) ...[
            const SizedBox(height: 12),
            FinancoSectionHeader(title: t.investments.sectionAccountPending),
            const SizedBox(height: 8),
            ...overview.accountBreakdown
                .where((s) => s.pending > 0 || s.hasOverflow)
                .map(
                  (slice) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InvestmentAccountPendingRow(
                      slice: slice,
                      onAllocate: () => onOpenHoldingSheet(
                        loaded: state,
                        presetAccountId: slice.accountId,
                      ),
                    ),
                  ),
                ),
          ],
          if (overview.orphanHoldingIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            _OrphanBanner(count: overview.orphanHoldingIds.length),
          ],
        ],
      ),
    );
  }
}

class _TargetsBanner extends StatelessWidget {
  const _TargetsBanner({required this.sum});

  final double sum;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.scaleBalanced,
            size: 14,
            color: colors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.investments.targetsBanner(percent: sum.toStringAsFixed(0)),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPlaceholder extends StatelessWidget {
  const _DonutPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.onBackgroundLight,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _OrphanBanner extends StatelessWidget {
  const _OrphanBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.wrench,
            size: 14,
            color: colors.onBackgroundLight,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.investments.orphanBanner(count: count),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
