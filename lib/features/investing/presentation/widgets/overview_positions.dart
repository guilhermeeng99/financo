import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/money_format.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/holding_valuation.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/presentation/asset_visuals.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The open positions list (quantity > 0), sorted by return (best first). Each
/// row shows the asset avatar, ticker + institution/quantity, base value with a
/// native-currency subline when they differ, and the position's P&L · return.
class OverviewPositions extends StatelessWidget {
  const OverviewPositions({
    required this.holdings,
    required this.assetsById,
    required this.institutionsById,
    super.key,
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
    final quantity = compactDecimal(holding.quantity, maxFractionDigits: 6);
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
