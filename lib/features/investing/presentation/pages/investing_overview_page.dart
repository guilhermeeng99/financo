import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/holding_valuation.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';
import 'package:financo/features/investing/presentation/cubit/investing_overview_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Net-worth landing for the investing module: a multi-currency total priced
/// from the local cache first, then refreshed from the network. See
/// `docs/specs/valuation.md`.
class InvestingOverviewPage extends StatelessWidget {
  const InvestingOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(title: t.investing.overview.title),
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
          return _OverviewBody(
            portfolio: loaded.portfolio,
            assetsById: loaded.assetsById,
            snapshots: loaded.snapshots,
            isRefreshing: loaded.isRefreshing,
          );
        },
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.portfolio,
    required this.assetsById,
    required this.snapshots,
    required this.isRefreshing,
  });

  final PortfolioValuation portfolio;
  final Map<String, Asset> assetsById;
  final List<Snapshot> snapshots;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final holdings = [...portfolio.holdings]
      ..sort((a, b) => b.marketValueBase.minorUnits.compareTo(
        a.marketValueBase.minorUnits,
      ));
    return RefreshIndicator(
      onRefresh: () =>
          context.read<InvestingOverviewCubit>().load(force: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _NetWorthHero(portfolio: portfolio, isRefreshing: isRefreshing),
          const SizedBox(height: 12),
          _StatsRow(portfolio: portfolio),
          if (snapshots.length > 1) ...[
            const SizedBox(height: 20),
            _History(snapshots: snapshots),
          ],
          if (portfolio.byCurrency.length > 1) ...[
            const SizedBox(height: 20),
            _ByCurrency(byCurrency: portfolio.byCurrency),
          ],
          const SizedBox(height: 24),
          Text(
            t.investing.overview.holdings,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.appColors.onBackgroundLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (final h in holdings)
            _HoldingTile(valuation: h, asset: assetsById[h.assetId]),
        ],
      ),
    );
  }
}

class _NetWorthHero extends StatelessWidget {
  const _NetWorthHero({required this.portfolio, required this.isRefreshing});

  final PortfolioValuation portfolio;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pl = portfolio.totalUnrealizedPL;
    final plColor = pl.isNegative ? colors.expense : colors.income;
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
              Text(
                t.investing.overview.netWorth,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onBackgroundLight,
                ),
              ),
              const SizedBox(width: 8),
              if (isRefreshing)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: colors.onBackgroundLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatMoney(portfolio.totalValueBase),
            style: context.textTheme.headlineMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FaIcon(
                pl.isNegative
                    ? FontAwesomeIcons.arrowTrendDown
                    : FontAwesomeIcons.arrowTrendUp,
                size: 12,
                color: plColor,
              ),
              const SizedBox(width: 6),
              Text(
                '${_signed(pl)} · ${_signedPct(portfolio.totalReturnPct)}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: plColor,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.portfolio});

  final PortfolioValuation portfolio;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: t.investing.overview.invested,
            value: formatMoney(portfolio.totalInvestedBase),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: t.investing.overview.unrealizedPl,
            value: _signed(portfolio.totalUnrealizedPL),
            valueColor: portfolio.totalUnrealizedPL.isNegative
                ? context.appColors.expense
                : context.appColors.income,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: valueColor ?? colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ByCurrency extends StatelessWidget {
  const _ByCurrency({required this.byCurrency});

  final Map<Currency, Money> byCurrency;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.investing.overview.byCurrency,
          style: context.textTheme.titleSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final amount in byCurrency.values)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formatMoney(amount),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({required this.valuation, required this.asset});

  final HoldingValuation valuation;
  final Asset? asset;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final plColor = valuation.unrealizedPL.isNegative
        ? colors.expense
        : colors.income;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          asset?.ticker ?? valuation.assetId,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: colors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (valuation.fxMissing)
                        _Badge(
                          label: t.investing.overview.fxMissing,
                          color: colors.expense,
                        )
                      else if (valuation.priceStale)
                        _Badge(
                          label: t.investing.overview.stale,
                          color: colors.onBackgroundLight,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_qty(valuation.quantity)} ${t.investing.overview.units}',
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
                  formatMoney(valuation.marketValueBase),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_signed(valuation.unrealizedPL)} · '
                  '${_signedPct(valuation.returnPct)}',
                  style: context.textTheme.bodySmall?.copyWith(color: plColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.snapshots});

  final List<Snapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final values = [
      for (final s in snapshots) s.totalValue.minorUnits.toDouble(),
    ];
    final first = snapshots.first.totalValue;
    final last = snapshots.last.totalValue;
    final delta = last - first;
    final lineColor = delta.isNegative ? colors.expense : colors.income;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.investing.overview.history,
          style: context.textTheme.titleSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 72,
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: CustomPaint(
            painter: _SparklinePainter(values: values, color: lineColor),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

/// Minimal line chart of the net-worth history — no axes, just the shape of the
/// trend. A flat series (all-equal) draws a centered horizontal line.
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    final dx = size.width / (values.length - 1);

    double yFor(double v) {
      if (range == 0) return size.height / 2;
      return size.height - ((v - min) / range) * size.height;
    }

    final path = Path()..moveTo(0, yFor(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(dx * i, yFor(values[i]));
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(
        fill,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.10),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

/// Signed money: `+R$ 10,00` / `-R$ 10,00` (the minus comes from the formatter).
String _signed(Money m) =>
    m.isNegative || m.isZero ? formatMoney(m) : '+${formatMoney(m)}';

/// Signed percentage from a ratio (0.12 → `+12.00%`).
String _signedPct(double ratio) {
  final pct = ratio * 100;
  final sign = pct > 0 ? '+' : '';
  return '$sign${pct.toStringAsFixed(2)}%';
}

/// Trims trailing zeros from a fractional quantity (3.0 → `3`, 1.5 → `1.5`).
String _qty(double quantity) {
  if (quantity == quantity.roundToDouble()) return quantity.toStringAsFixed(0);
  return quantity
      .toStringAsFixed(8)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
