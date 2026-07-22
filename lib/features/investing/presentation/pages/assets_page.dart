import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/fixed_income_terms.dart';
import 'package:financo/features/investing/presentation/cubit/assets_cubit.dart';
import 'package:financo/features/investing/presentation/widgets/investing_assets_csv_import_dialog.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Lists the user's investing assets. See `docs/specs/investing_assets.md`.
class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<AssetsCubit>().load());
  }

  Future<void> _openForm([Asset? existing]) async {
    final route = existing == null ? AppRoutes.addAsset : AppRoutes.editAsset;
    final result = await context.push<bool>(route, extra: existing);
    if (result == true && mounted) {
      unawaited(context.read<AssetsCubit>().load(forceRefresh: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.investing.assets.title,
        showBack: true,
        actions: [
          IconButton(
            tooltip: t.investing.assets.import.cta,
            icon: const FaIcon(FontAwesomeIcons.fileImport, size: 18),
            onPressed: () =>
                unawaited(showInvestingAssetsCsvImportDialog(context)),
          ),
        ],
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'assets_fab',
          onPressed: _openForm,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: BlocBuilder<AssetsCubit, AssetsState>(
        builder: (context, state) {
          if (state is AssetsLoading || state is AssetsImporting) {
            return const LoadingShimmer();
          }
          if (state is AssetsError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () =>
                  context.read<AssetsCubit>().load(forceRefresh: true),
            );
          }
          final assets = state is AssetsLoaded ? state.assets : const <Asset>[];
          if (assets.isEmpty) {
            return FeatureEmptyState(
              icon: FontAwesomeIcons.chartLine,
              title: t.investing.assets.emptyTitle,
              message: t.investing.assets.empty,
              actionLabel: t.investing.assets.addFirst,
              onAction: _openForm,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: assets.length,
            itemBuilder: (_, i) =>
                _AssetTile(asset: assets[i], onTap: () => _openForm(assets[i])),
          );
        },
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.asset, required this.onTap});

  final Asset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.surfaceVariant,
                  child: Text(
                    asset.ticker.characters.take(2).toString().toUpperCase(),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
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
                        asset.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      assetKindLabel(asset.kind),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      asset.currency.code,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colors.onBackgroundLight,
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
}

/// Localized label for an [AssetKind].
String assetKindLabel(AssetKind kind) => switch (kind) {
  AssetKind.stockBr => t.investing.assets.kinds.stockBr,
  AssetKind.fiiBr => t.investing.assets.kinds.fiiBr,
  AssetKind.etfBr => t.investing.assets.kinds.etfBr,
  AssetKind.bdrBr => t.investing.assets.kinds.bdrBr,
  AssetKind.stockUs => t.investing.assets.kinds.stockUs,
  AssetKind.etfUs => t.investing.assets.kinds.etfUs,
  AssetKind.crypto => t.investing.assets.kinds.crypto,
  AssetKind.treasury => t.investing.assets.kinds.treasury,
  AssetKind.fixedIncome => t.investing.assets.kinds.fixedIncome,
  AssetKind.fund => t.investing.assets.kinds.fund,
  AssetKind.cash => t.investing.assets.kinds.cash,
};

/// Localized label for a [Market].
String marketLabel(Market market) => switch (market) {
  Market.br => t.investing.assets.markets.br,
  Market.us => t.investing.assets.markets.us,
  Market.global => t.investing.assets.markets.global,
};

/// Localized label for a [FixedIncomeBasis].
String fixedIncomeBasisLabel(FixedIncomeBasis basis) => switch (basis) {
  FixedIncomeBasis.cdi => t.investing.assets.fiBases.cdi,
  FixedIncomeBasis.selic => t.investing.assets.fiBases.selic,
  FixedIncomeBasis.prefixed => t.investing.assets.fiBases.prefixed,
  FixedIncomeBasis.ipca => t.investing.assets.fiBases.ipca,
};
