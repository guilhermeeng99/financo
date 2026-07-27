import 'dart:async';

import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/features/investing/domain/entities/portfolio_valuation.dart';
import 'package:financo/features/investing/presentation/cubit/institutions_cubit.dart';
import 'package:financo/features/investing/presentation/cubit/investing_overview_cubit.dart';
import 'package:financo/features/investing/presentation/widgets/overview_allocation_by_class.dart';
import 'package:financo/features/investing/presentation/widgets/overview_hero.dart';
import 'package:financo/features/investing/presentation/widgets/overview_institution_filter.dart';
import 'package:financo/features/investing/presentation/widgets/overview_metrics.dart';
import 'package:financo/features/investing/presentation/widgets/overview_positions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
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
                OverviewInstitutionFilter(
                  institutionIds: filterableIds,
                  institutionsById: institutionsById,
                  selected: activeFilter,
                  onSelect: (id) => setState(() => _filter = id),
                ),
                const SizedBox(height: 12),
              ],
              OverviewHero(portfolio: visible),
              const SizedBox(height: 12),
              OverviewMetrics(portfolio: visible),
              if (visible.byClass.isNotEmpty) ...[
                const SizedBox(height: 16),
                OverviewAllocationByClass(byClass: visible.byClass),
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
              OverviewPositions(
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
