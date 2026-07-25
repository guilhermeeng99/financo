import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/extensions/context_user_extensions.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/dynamic_icon.dart';import 'package:financo/features/investing/domain/entities/allocation_overview.dart';
import 'package:financo/features/investing/presentation/cubit/investing_allocation_cubit.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_classes_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Current-vs-target allocation over market value, with rebalance suggestions.
/// See `docs/specs/allocation.md`.
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
          return _AllocationBody(
            overview: loaded.overview,
            onEditClass: (classId) =>
                unawaited(_openClassForm(context, classId: classId)),
          );
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
  const _AllocationBody({required this.overview, required this.onEditClass});

  final AllocationOverview overview;
  final void Function(String classId) onEditClass;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<InvestingAllocationCubit>().load(force: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _Totals(overview: overview),
          if (!overview.targetsBalanced) ...[
            const SizedBox(height: 12),
            _Banner(
              icon: FontAwesomeIcons.triangleExclamation,
              text: t.investing.allocation.targetsUnbalanced(
                percent: _pct(overview.targetSumPercent / 100),
              ),
            ),
          ],
          const SizedBox(height: 20),
          for (final slice in overview.slices)
            _ClassRow(
              slice: slice,
              onTap: () => onEditClass(slice.classId),
            ),
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

class _Totals extends StatelessWidget {
  const _Totals({required this.overview});

  final AllocationOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatMoney(overview.totalValue),
            style: context.textTheme.headlineSmall?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${t.investing.allocation.allocated}: '
            '${formatMoney(overview.allocatedValue)}'
            '${overview.hasUnallocated ? ' · '
                      '${t.investing.allocation.unallocated}: '
                      '${formatMoney(overview.unallocatedValue)}' : ''}',
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.slice, required this.onTap});

  final AllocationClassSlice slice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final classColor = Color(slice.color);
    final deltaLabel = _deltaLabel(slice);
    final deltaColor =
        slice.delta.minorUnits.abs() < AllocationSliceThreshold.minor
        ? colors.onBackgroundLight
        : (slice.isUnderTarget ? colors.income : colors.expense);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
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
                      child: Text(
                        slice.name,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formatMoney(slice.currentValue),
                      style: context.textTheme.titleSmall?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _AllocationBar(
                  current: slice.currentPercent,
                  target: slice.targetPercent,
                  color: classColor,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t.investing.allocation.current} '
                      '${_pct(slice.currentPercent)} · '
                      '${t.investing.allocation.target} '
                      '${_pct(slice.targetPercent)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    Text(
                      deltaLabel,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: deltaColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _deltaLabel(AllocationClassSlice slice) {
    if (slice.delta.minorUnits.abs() < AllocationSliceThreshold.minor) {
      return t.investing.allocation.onTarget;
    }
    final verb = slice.isUnderTarget
        ? t.investing.allocation.buy
        : t.investing.allocation.sell;
    final amount = Money(slice.delta.minorUnits.abs(), slice.delta.currency);
    return '$verb ${formatMoney(amount)}';
  }
}

/// A thin bar: fill = current share of the portfolio, tick = target share.
class _AllocationBar extends StatelessWidget {
  const _AllocationBar({
    required this.current,
    required this.target,
    required this.color,
  });

  final double current;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fill = current.clamp(0.0, 1.0) * width;
        final tick = target.clamp(0.0, 1.0) * width;
        // Guard the tick's max offset: a mid-layout width of 0 would make
        // `width - 2` negative and `clamp` assert (min > max).
        final maxTickLeft = width > 2 ? width - 2 : 0.0;
        return SizedBox(
          height: 8,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: fill,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Positioned(
                left: (tick - 1).clamp(0.0, maxTickLeft),
                child: Container(
                  width: 2,
                  height: 8,
                  color: colors.onBackground,
                ),
              ),
            ],
          ),
        );
      },
    );
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

/// Mirror of `AllocationService.rebalanceThresholdMinor` for the UI's on-target
/// styling, kept here so the page doesn't import the service.
abstract final class AllocationSliceThreshold {
  static const minor = 100;
}

String _pct(double fraction) => '${(fraction * 100).toStringAsFixed(1)}%';
