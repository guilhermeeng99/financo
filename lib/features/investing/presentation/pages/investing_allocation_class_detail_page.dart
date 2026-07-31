import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/extensions/context_navigation_extensions.dart';
import 'package:financo/core/extensions/context_user_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/core/utils/money_format.dart';
import 'package:financo/features/investing/domain/entities/allocation_overview.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/services/allocation_service.dart';
import 'package:financo/features/investing/domain/usecases/get_assets_usecase.dart';
import 'package:financo/features/investing/presentation/allocation_slice_display.dart';
import 'package:financo/features/investing/presentation/cubit/investing_allocation_cubit.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/features/investments/domain/usecases/get_asset_classes_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Detail of one allocation class: its target progress plus the assets in it,
/// each with a within-class target share and a suggested aporte/trim to reach
/// it. Reads the shell-scoped [InvestingAllocationCubit] and picks the class by
/// [classId] from the already-computed overview. Ported from Investanco's
/// `AssetClassDetailPage`. See `docs/specs/allocation.md`.
class AllocationClassDetailPage extends StatelessWidget {
  const AllocationClassDetailPage({required this.classId, super.key});

  final String classId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvestingAllocationCubit, InvestingAllocationState>(
      // The class was deleted (or lost all assets and rolled off) while open —
      // return to the list rather than showing an empty shell.
      listenWhen: (previous, current) =>
          current is InvestingAllocationLoaded &&
          _sliceIn(current, classId) == null,
      listener: (context, state) =>
          context.popOrGo(AppRoutes.investingAllocation),
      builder: (context, state) {
        final slice = state is InvestingAllocationLoaded
            ? _sliceIn(state, classId)
            : null;
        return Scaffold(
          appBar: FinancoLargeAppBar(
            title: slice?.name ?? t.investing.allocation.title,
            showBack: true,
            actions: [
              if (slice != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 4),
                  child: FinancoAppBarIconButton(
                    icon: FontAwesomeIcons.penToSquare,
                    color: context.appColors.primary,
                    tooltip: t.general.edit,
                    onPressed: () => unawaited(_editClass(context)),
                  ),
                ),
            ],
          ),
          body: switch (state) {
            InvestingAllocationLoading() => const LoadingShimmer(),
            InvestingAllocationError() => ErrorView(
              failure: state.failure,
              onRetry: () =>
                  context.read<InvestingAllocationCubit>().load(force: true),
            ),
            InvestingAllocationLoaded() =>
              slice == null
                  ? const SizedBox.shrink()
                  : _DetailBody(slice: slice),
          },
        );
      },
    );
  }

  static AllocationClassSlice? _sliceIn(
    InvestingAllocationLoaded state,
    String classId,
  ) {
    for (final slice in state.overview.slices) {
      if (slice.classId == classId) return slice;
    }
    return null;
  }

  /// Opens the class edit form (surviving V1 `asset_classes` flow) and
  /// refreshes the allocation on a successful save.
  Future<void> _editClass(BuildContext context) async {
    final result = await GetIt.I<GetAssetClassesUseCase>()(
      userId: context.currentUserId,
    );
    AssetClassEntity? existing;
    for (final c in result.getOrElse(() => const [])) {
      if (c.id == classId) {
        existing = c;
        break;
      }
    }
    if (existing == null || !context.mounted) return;
    final saved = await context.push<bool>(
      AppRoutes.assetClass,
      extra: existing,
    );
    if (saved == true && context.mounted) {
      unawaited(context.read<InvestingAllocationCubit>().load(force: true));
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.slice});

  final AllocationClassSlice slice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        _HeroCard(slice: slice),
        const SizedBox(height: 20),
        Text(
          t.investing.allocation.assets,
          style: context.textTheme.titleSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (slice.assets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              t.investing.allocation.noAssets,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          )
        else
          for (final asset in slice.assets)
            _AssetRow(
              asset: asset,
              tint: Color(slice.color),
              onTap: () => unawaited(_editAsset(context, asset.assetId)),
            ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () => unawaited(_addAsset(context)),
            child: Text(t.investing.allocation.addAsset),
          ),
        ),
      ],
    );
  }

  /// Opens the asset form pre-selecting this class, then refreshes.
  Future<void> _addAsset(BuildContext context) async {
    final saved = await context.push<bool>(
      '${AppRoutes.addAsset}?classId=${slice.classId}',
    );
    if (saved == true && context.mounted) {
      unawaited(context.read<InvestingAllocationCubit>().load(force: true));
    }
  }

  /// Opens the edit form for the tapped asset, then refreshes.
  Future<void> _editAsset(BuildContext context, String assetId) async {
    final result = await GetIt.I<GetAssetsUseCase>()(
      userId: context.currentUserId,
    );
    Asset? asset;
    for (final a in result.getOrElse(() => const [])) {
      if (a.id == assetId) {
        asset = a;
        break;
      }
    }
    if (asset == null || !context.mounted) return;
    final saved = await context.push<bool>(AppRoutes.editAsset, extra: asset);
    if (saved == true && context.mounted) {
      unawaited(context.read<InvestingAllocationCubit>().load(force: true));
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.slice});

  final AllocationClassSlice slice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = Color(slice.color);
    final actual = slice.actualPercentLabel;
    final target = slice.targetPercentLabel;
    final deltaColor = slice.deltaColor(colors);
    final deltaLabel = slice.deltaLabel;
    final progress = slice.progress;

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
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: tint.withValues(alpha: 0.18),
                child: Icon(materialIconFor(slice.icon), size: 20, color: tint),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatMoney(slice.currentValue),
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(tint),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.investing.allocation.targetAmount(
                  amount: formatMoney(slice.targetValue),
                ),
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
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({
    required this.asset,
    required this.tint,
    required this.onTap,
  });

  final AllocationAssetSlice asset;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actual = percentWhole(asset.percentOfClass);
    final target = asset.targetPercent.toStringAsFixed(0);
    final hasTarget = asset.targetPercent > 0;
    final deltaMinor = asset.suggestedDelta.minorUnits;
    final isBelow =
        hasTarget && deltaMinor >= AllocationService.rebalanceThresholdMinor;
    final isAbove =
        hasTarget && deltaMinor <= -AllocationService.rebalanceThresholdMinor;
    final suggestionColor = !hasTarget
        ? colors.onBackgroundLight
        : isBelow
        ? colors.income
        : (isAbove ? colors.expense : colors.onBackgroundLight);
    final suggestionLabel = !hasTarget
        ? t.investing.allocation.assetNoTarget
        : isBelow
        ? t.investing.allocation.assetAdd(amount: _suggestionAmount())
        : (isAbove
              ? t.investing.allocation.assetTrim(amount: _suggestionAmount())
              : t.investing.allocation.onTarget);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.ticker,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasTarget
                            ? t.investing.allocation.assetLineTarget(
                                amount: formatMoney(asset.currentValue),
                                actual: '$actual%',
                                target: '$target%',
                              )
                            : t.investing.allocation.assetLine(
                                amount: formatMoney(asset.currentValue),
                                percent: '$actual%',
                              ),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                      ),
                      const SizedBox(height: 2),
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
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 11,
                  color: colors.onBackgroundLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The aporte/trim amount, base currency plus the asset's own currency in
  /// parentheses when the two differ (e.g. "R$ 3.495,32 (US$ 688,26)").
  String _suggestionAmount() {
    final base = absMoney(asset.suggestedDelta);
    final native = asset.suggestedDeltaNative;
    if (native == null) return base;
    return '$base (${absMoney(native)})';
  }
}
