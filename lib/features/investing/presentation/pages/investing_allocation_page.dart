import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/extensions/context_user_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/core/utils/money_format.dart';
import 'package:financo/features/investing/domain/entities/allocation_overview.dart';
import 'package:financo/features/investing/domain/services/allocation_service.dart';
import 'package:financo/features/investing/presentation/cubit/investing_allocation_cubit.dart';
import 'package:financo/features/investing/presentation/widgets/allocation_class_donut.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_classes_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Current-vs-target allocation over market value: a donut of the current mix,
/// per-class rows (current% of target% + how far above/below), and rebalance
/// suggestions. Tapping a class opens its per-asset detail. See
/// `docs/specs/allocation.md`.
class InvestingAllocationPage extends StatelessWidget {
  const InvestingAllocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.investing.allocation.title,
        showBack: true,
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'allocation_class_fab',
          onPressed: () => unawaited(_openClassForm(context)),
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: BlocBuilder<InvestingAllocationCubit, InvestingAllocationState>(
        builder: (context, state) {
          if (state is InvestingAllocationLoading) {
            return const LoadingShimmer();
          }
          if (state is InvestingAllocationError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () =>
                  context.read<InvestingAllocationCubit>().load(force: true),
            );
          }
          final loaded = state as InvestingAllocationLoaded;
          if (loaded.overview.slices.isEmpty) {
            return FeatureEmptyState(
              icon: FontAwesomeIcons.chartPie,
              title: t.investing.allocation.emptyTitle,
              message: t.investing.allocation.empty,
              actionLabel: t.investing.allocation.addClass,
              onAction: () => unawaited(_openClassForm(context)),
            );
          }
          return _AllocationBody(overview: loaded.overview);
        },
      ),
    );
  }

  /// Opens the allocation-class form (add when [classId] is null, edit
  /// otherwise) and refreshes on a successful save. The class stack is the
  /// surviving V1 `asset_classes` feature — its form is the only place these
  /// buckets are created/edited. The entity is fetched by id for edit because
  /// the priced overview only carries the lightweight [AllocationClassSlice].
  Future<void> _openClassForm(BuildContext context, {String? classId}) async {
    AssetClassEntity? existing;
    if (classId != null) {
      final result = await GetIt.I<GetAssetClassesUseCase>()(
        userId: _userId(context),
      );
      for (final c in result.getOrElse(() => const [])) {
        if (c.id == classId) {
          existing = c;
          break;
        }
      }
    }
    if (!context.mounted) return;
    final saved = await context.push<bool>(
      AppRoutes.assetClass,
      extra: existing,
    );
    if (saved == true && context.mounted) {
      unawaited(context.read<InvestingAllocationCubit>().load(force: true));
    }
  }

  String _userId(BuildContext context) => context.currentUserId;
}

class _AllocationBody extends StatelessWidget {
  const _AllocationBody({required this.overview});

  final AllocationOverview overview;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<InvestingAllocationCubit>().load(force: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          AllocationClassDonut(overview: overview),
          if (!overview.targetsBalanced) ...[
            const SizedBox(height: 12),
            _Banner(
              icon: FontAwesomeIcons.triangleExclamation,
              text: t.investing.allocation.targetsUnbalanced(
                percent: percentFraction(overview.targetSumPercent / 100),
              ),
            ),
          ],
          const SizedBox(height: 20),
          for (final slice in overview.slices) _ClassRow(slice: slice),
          if (overview.rebalanceActions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              t.investing.allocation.rebalance,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.appColors.onBackgroundLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (final action in overview.rebalanceActions)
              _RebalanceRow(action: action),
          ],
          if (overview.hasUnallocated) ...[
            const SizedBox(height: 16),
            _Banner(
              icon: FontAwesomeIcons.circleQuestion,
              text: t.investing.allocation.unallocatedHint(
                amount: formatMoney(overview.unallocatedValue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A root-class row: icon, name, "X% of Y%", value, "R$ X above/below", and a
/// full-color bar filling current/target (capped at full when over target).
/// Tapping opens the class detail. Mirrors Investanco's `InvestmentClassRow`.
class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.slice});

  final AllocationClassSlice slice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final classColor = Color(slice.color);
    final actual = (slice.currentPercent * 100).toStringAsFixed(0);
    final target = (slice.targetPercent * 100).toStringAsFixed(0);
    final onTarget =
        slice.delta.minorUnits.abs() <
        AllocationService.rebalanceThresholdMinor;
    final deltaColor = onTarget
        ? colors.onBackgroundLight
        : (slice.isUnderTarget ? colors.income : colors.expense);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () =>
              context.push(AppRoutes.allocationClassById(slice.classId)),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: classColor.withValues(alpha: 0.15),
                      child: Icon(
                        materialIconFor(slice.icon),
                        size: 16,
                        color: classColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slice.name,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: colors.onBackground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.investing.allocation.classRowSubtitle(
                              actual: '$actual%',
                              target: '$target%',
                            ),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onBackgroundLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatMoney(slice.currentValue),
                          style: context.textTheme.titleSmall?.copyWith(
                            color: colors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _deltaLabel(),
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
                    value: _progress(),
                    minHeight: 8,
                    backgroundColor: colors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(classColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bar fills current/target, capped at full when over target.
  double _progress() {
    final target = slice.targetPercent;
    if (target <= 0) return slice.currentPercent.clamp(0.0, 1.0);
    return (slice.currentPercent / target).clamp(0.0, 1.0);
  }

  String _deltaLabel() {
    if (slice.delta.minorUnits.abs() <
        AllocationService.rebalanceThresholdMinor) {
      return t.investing.allocation.onTarget;
    }
    final amount = absMoney(slice.delta);
    return slice.isUnderTarget
        ? t.investing.allocation.below(amount: amount)
        : t.investing.allocation.above(amount: amount);
  }
}

class _RebalanceRow extends StatelessWidget {
  const _RebalanceRow({required this.action});

  final RebalanceAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isBuy = action.direction == RebalanceDirection.buy;
    final color = isBuy ? colors.income : colors.expense;
    final verb = isBuy
        ? t.investing.allocation.buy
        : t.investing.allocation.sell;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            FaIcon(
              isBuy ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$verb ${action.name}',
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onBackground,
                ),
              ),
            ),
            Text(
              formatMoney(action.amount),
              style: context.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text});

  /// A FontAwesome glyph; [FaIcon] carries the right font family.
  final FaIconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: colors.onBackgroundLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
