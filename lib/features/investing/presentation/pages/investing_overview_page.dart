import 'dart:async';

import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/money_format.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/holding_valuation.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/presentation/asset_visuals.dart';
import 'package:financo/features/investing/presentation/cubit/institutions_cubit.dart';
import 'package:financo/features/investing/presentation/cubit/investing_overview_cubit.dart';
import 'package:financo/features/investing/presentation/pages/assets_page.dart'
    show assetKindLabel;
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Net-worth landing for the investing module: a gradient hero, key metrics,
/// allocation by class, and the positions — scoped by an optional institution
/// filter. Ported from Investanco's portfolio dashboard. See
/// `docs/specs/valuation.md`.
class InvestingOverviewPage extends StatelessWidget {
  const InvestingOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.investing.overview.title,
        actions: const [_OverviewRefreshAction()],
      ),
      body: BlocBuilder<InvestingOverviewCubit, InvestingOverviewState>(
        builder: (context, state) {
          if (state is InvestingOverviewLoading) {
            return const LoadingShimmer();
          }
          if (state is InvestingOverviewError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () =>
                  context.read<InvestingOverviewCubit>().load(force: true),
            );
          }
          final loaded = state as InvestingOverviewLoaded;
          if (loaded.portfolio.holdings.isEmpty) {
            return FeatureEmptyState(
              icon: FontAwesomeIcons.chartLine,
              title: t.investing.overview.emptyTitle,
              message: t.investing.overview.empty,
            );
          }
          return _PortfolioView(
            portfolio: loaded.portfolio,
            assetsById: loaded.assetsById,
          );
        },
      ),
    );
  }
}

/// App-bar refresh action: forces a network re-pull of quotes/FX
/// (`load(force: true)`), swapping to an inline spinner while in flight.
class _OverviewRefreshAction extends StatelessWidget {
  const _OverviewRefreshAction();

  static bool _isRefreshing(InvestingOverviewState state) =>
      state is InvestingOverviewLoaded && state.isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 4),
      child: BlocBuilder<InvestingOverviewCubit, InvestingOverviewState>(
        buildWhen: (previous, current) =>
            _isRefreshing(previous) != _isRefreshing(current),
        builder: (context, state) {
          if (_isRefreshing(state)) {
            return SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.appColors.primary,
                  ),
                ),
              ),
            );
          }
          return FinancoAppBarIconButton(
            icon: FontAwesomeIcons.arrowsRotate,
            color: context.appColors.primary,
            tooltip: t.investing.overview.refresh,
            onPressed: () => unawaited(
              context.read<InvestingOverviewCubit>().load(force: true),
            ),
          );
        },
      ),
    );
  }
}

/// The loaded portfolio, scoped by an optional institution filter (chips shown
/// when more than one institution holds value). Institution names come from the
/// shell-scoped [InstitutionsCubit].
class _PortfolioView extends StatefulWidget {
  const _PortfolioView({required this.portfolio, required this.assetsById});

  final PortfolioValuation portfolio;
  final Map<String, Asset> assetsById;

  @override
  State<_PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<_PortfolioView> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstitutionsCubit, InstitutionsState>(
      builder: (context, instState) {
        final institutions = instState is InstitutionsLoaded
            ? instState.institutions
            : const <Institution>[];
        final institutionsById = {for (final i in institutions) i.id: i};

        final full = widget.portfolio;
        // Institutions that currently hold value, biggest first — the chips.
        final filterableIds =
            (full.byInstitution.entries
                    .where((e) => e.value.minorUnits > 0)
                    .toList()
                  ..sort(
                    (a, b) => b.value.minorUnits.compareTo(a.value.minorUnits),
                  ))
                .map((e) => e.key)
                .toList();
        // Keep the active filter valid if its institution dropped to zero.
        final activeFilter = _filter != null && filterableIds.contains(_filter)
            ? _filter
            : null;
        final visible = activeFilter == null
            ? full
            : full.forInstitution(activeFilter);

        return RefreshIndicator(
          onRefresh: () =>
              context.read<InvestingOverviewCubit>().load(force: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              if (filterableIds.length > 1) ...[
                _InstitutionFilter(
                  institutionIds: filterableIds,
                  institutionsById: institutionsById,
                  selected: activeFilter,
                  onSelect: (id) => setState(() => _filter = id),
                ),
                const SizedBox(height: 12),
              ],
              _Hero(portfolio: visible),
              const SizedBox(height: 12),
              _Metrics(portfolio: visible),
              if (visible.byClass.isNotEmpty) ...[
                const SizedBox(height: 16),
                _AllocationByClass(byClass: visible.byClass),
              ],
              const SizedBox(height: 20),
              Text(
                t.investing.overview.holdings,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.appColors.onBackgroundLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _Positions(
                holdings: visible.holdings,
                assetsById: widget.assetsById,
                institutionsById: institutionsById,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InstitutionFilter extends StatelessWidget {
  const _InstitutionFilter({
    required this.institutionIds,
    required this.institutionsById,
    required this.selected,
    required this.onSelect,
  });

  final List<String> institutionIds;
  final Map<String, Institution> institutionsById;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _FilterChip(
            label: t.investing.overview.filterAll,
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final id in institutionIds) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: institutionsById[id]?.name ?? id,
              selected: selected == id,
              onTap: () => onSelect(id),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary.withValues(alpha: 0.14) : colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: selected ? colors.primary : colors.onBackgroundLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.portfolio});

  final PortfolioValuation portfolio;

  @override
  Widget build(BuildContext context) {
    final ret = portfolio.totalReturnPct;
    final up = ret >= 0;
    final base = portfolio.totalValueBase.currency;
    final foreign = [
      for (final e in portfolio.byCurrency.entries)
        if (e.key != base && e.value.minorUnits > 0) e.value,
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A868), Color(0xFF007A4D)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.investing.overview.totalNetWorth,
            style: context.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatMoney(portfolio.totalValueBase),
            style: context.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  up
                      ? FontAwesomeIcons.arrowTrendUp
                      : FontAwesomeIcons.arrowTrendDown,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  signedPercent(ret),
                  style: context.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          for (final money in foreign) ...[
            const SizedBox(height: 12),
            Text(
              '${t.investing.overview.inCurrency(code: money.currency.code)}'
              '  ·  ${formatMoney(money)}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.portfolio});

  final PortfolioValuation portfolio;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricTile(
              label: t.investing.overview.invested,
              value: formatMoney(portfolio.totalInvestedBase),
            ),
          ),
          _divider(colors.surfaceVariant),
          Expanded(
            child: _MetricTile(
              label: t.investing.overview.unrealizedPl,
              value: signedMoney(portfolio.totalUnrealizedPL),
              valueColor: portfolio.totalUnrealizedPL.isNegative
                  ? colors.expense
                  : colors.income,
            ),
          ),
          _divider(colors.surfaceVariant),
          Expanded(
            child: _MetricTile(
              label: t.investing.overview.dayChange,
              value: signedMoney(portfolio.totalDayChangeBase),
              valueColor: portfolio.totalDayChangeBase.isNegative
                  ? colors.expense
                  : colors.income,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(Color color) => Container(
    width: 1,
    height: 36,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: color,
  );
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(
            color: valueColor ?? colors.onBackground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AllocationByClass extends StatelessWidget {
  const _AllocationByClass({required this.byClass});

  final Map<AssetKind, Money> byClass;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final entries =
        byClass.entries.where((e) => e.value.minorUnits > 0).toList()
          ..sort((a, b) => b.value.minorUnits.compareTo(a.value.minorUnits));
    if (entries.isEmpty) return const SizedBox.shrink();
    final totalMinor = entries.fold<int>(0, (s, e) => s + e.value.minorUnits);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.investing.overview.allocationByClass,
            style: context.textTheme.titleSmall?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 42,
                    sections: [
                      for (final e in entries)
                        PieChartSectionData(
                          value: e.value.minorUnits.toDouble(),
                          color: assetKindColor(e.key),
                          radius: 22,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (final e in entries)
                      _LegendRow(
                        color: assetKindColor(e.key),
                        label: assetKindLabel(e.key),
                        fraction: totalMinor == 0
                            ? 0
                            : e.value.minorUnits / totalMinor,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.fraction,
  });

  final Color color;
  final String label;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ),
          Text(
            '${(fraction * 100).toStringAsFixed(0)}%',
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Positions extends StatelessWidget {
  const _Positions({
    required this.holdings,
    required this.assetsById,
    required this.institutionsById,
  });

  final List<HoldingValuation> holdings;
  final Map<String, Asset> assetsById;
  final Map<String, Institution> institutionsById;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final open = holdings.where((h) => h.quantity > 0).toList()
      ..sort((a, b) => b.returnPct.compareTo(a.returnPct));
    if (open.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < open.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.surfaceVariant),
            _PositionTile(
              holding: open[i],
              asset: assetsById[open[i].assetId],
              institution: institutionsById[open[i].institutionId],
            ),
          ],
        ],
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  const _PositionTile({
    required this.holding,
    required this.asset,
    required this.institution,
  });

  final HoldingValuation holding;
  final Asset? asset;
  final Institution? institution;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ticker = asset?.ticker ?? holding.assetId;
    final quantity = _trimQuantity(holding.quantity);
    final subtitle = institution == null
        ? quantity
        : '${institution!.name}  ·  $quantity';
    final plColor = holding.unrealizedPL.isNegative
        ? colors.expense
        : colors.income;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          AssetAvatar(kind: holding.assetKind, ticker: ticker),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ticker,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (holding.priceStale) ...[
                      const SizedBox(width: 6),
                      FaIcon(
                        FontAwesomeIcons.clock,
                        size: 11,
                        color: colors.onBackgroundLight,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onBackgroundLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (holding.fxMissing)
            Text(
              '—',
              style: context.textTheme.titleSmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(holding.marketValueBase),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (holding.marketValueNative.currency !=
                    holding.marketValueBase.currency) ...[
                  const SizedBox(height: 1),
                  Text(
                    formatMoney(holding.marketValueNative),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  '${signedMoney(holding.unrealizedPL)} · '
                  '${signedPercent(holding.returnPct)}',
                  style: context.textTheme.bodySmall?.copyWith(color: plColor),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Trims a share quantity to a compact string (drops trailing zeros).
String _trimQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity
      .toStringAsFixed(6)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}
