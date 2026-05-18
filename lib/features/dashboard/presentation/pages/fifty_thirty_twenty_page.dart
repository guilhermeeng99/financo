import 'dart:async';

import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_month_filter_pill.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/responsive_layout.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/dashboard/domain/usecases/get_fifty_thirty_twenty_history_usecase.dart';
import 'package:financo/features/dashboard/presentation/cubit/fifty_thirty_twenty_detail_cubit.dart';
import 'package:financo/features/dashboard/presentation/cubit/fifty_thirty_twenty_targets_cubit.dart';
import 'package:financo/features/dashboard/presentation/widgets/fifty_thirty_twenty_breakdown_section.dart';
import 'package:financo/features/dashboard/presentation/widgets/fifty_thirty_twenty_card.dart';
import 'package:financo/features/dashboard/presentation/widgets/fifty_thirty_twenty_history_chart.dart';
import 'package:financo/features/dashboard/presentation/widgets/fifty_thirty_twenty_targets_sheet.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

/// Dedicated detail view for the 50/30/20 rule. Hosts the big card, a
/// per-bucket breakdown of the period's expenses, a 3-month history
/// chart, and a settings affordance for editing the target split.
///
/// Loaded by the `Planejamento` shell tab as one of two sub-tabs; can
/// also be reached by tapping the dashboard card.
class FiftyThirtyTwentyPage extends StatelessWidget {
  const FiftyThirtyTwentyPage({super.key, this.embedded = false});

  /// When `true`, the page is mounted as a sub-tab and skips its own
  /// `FinancoLargeAppBar` — the parent shell hosts the title and the
  /// targets-editor action. The settings affordance still has to live
  /// somewhere, so embedded mode surfaces it inline as a chip at the
  /// top of the body.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';
    return BlocProvider(
      create: (_) => FiftyThirtyTwentyDetailCubit(
        getAccounts: GetIt.I<GetAccountsUseCase>(),
        getCategories: GetIt.I<GetCategoriesUseCase>(),
        getTransactions: GetIt.I<GetTransactionsUseCase>(),
        getHistory: GetIt.I<GetFiftyThirtyTwentyHistoryUseCase>(),
        userId: userId,
      ),
      child: _FiftyThirtyTwentyView(embedded: embedded),
    );
  }
}

class _FiftyThirtyTwentyView extends StatefulWidget {
  const _FiftyThirtyTwentyView({required this.embedded});

  final bool embedded;

  @override
  State<_FiftyThirtyTwentyView> createState() => _FiftyThirtyTwentyViewState();
}

class _FiftyThirtyTwentyViewState extends State<_FiftyThirtyTwentyView> {
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final filter = context.read<DateFilterCubit>().state;
    final targets = context.read<FiftyThirtyTwentyTargetsCubit>().state.targets;
    final month = DateTime(filter.year, filter.month);
    unawaited(
      context.read<FiftyThirtyTwentyDetailCubit>().load(
        month: month,
        targets: targets,
      ),
    );
  }

  Future<void> _openTargetsEditor() async {
    final cubit = context.read<FiftyThirtyTwentyTargetsCubit>();
    await showFiftyThirtyTwentyTargetsSheet(
      context: context,
      cubit: cubit,
    );
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.embedded
          ? null
          : FinancoLargeAppBar(
              title: t.fiftyThirtyTwenty.title,
              actions: [
                IconButton(
                  onPressed: () {
                    unawaited(_openTargetsEditor());
                  },
                  tooltip: t.fiftyThirtyTwenty.editTargets,
                  icon: const FaIcon(FontAwesomeIcons.sliders, size: 16),
                ),
              ],
            ),
      // Embedded mode surfaces the "edit targets" action as a floating
      // affordance pinned to the top-right of the list — parent shell
      // owns the title, but the action still belongs to this view.
      floatingActionButton: widget.embedded
          ? FloatingActionButton.small(
              heroTag: 'fifty_thirty_twenty_targets_fab',
              onPressed: () => unawaited(_openTargetsEditor()),
              tooltip: t.fiftyThirtyTwenty.editTargets,
              child: const FaIcon(FontAwesomeIcons.sliders, size: 14),
            )
          : null,
      body: MultiBlocListener(
        listeners: [
          BlocListener<DateFilterCubit, DateFilterState>(
            listener: (context, state) => _reload(),
          ),
          BlocListener<FiftyThirtyTwentyTargetsCubit,
              FiftyThirtyTwentyTargetsState>(
            listenWhen: (previous, current) =>
                previous.targets != current.targets,
            listener: (context, state) => _reload(),
          ),
        ],
        child: BlocBuilder<FiftyThirtyTwentyDetailCubit,
            FiftyThirtyTwentyDetailState>(
          builder: (context, state) {
            if (state.status == FiftyThirtyTwentyDetailStatus.loading ||
                state.status == FiftyThirtyTwentyDetailStatus.initial) {
              return const LoadingShimmer();
            }
            if (state.status == FiftyThirtyTwentyDetailStatus.error) {
              return ErrorView(
                message: state.failure?.message ?? t.general.error,
                onRetry: _reload,
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                if (isMobile) ...const [
                  Center(child: FinancoMonthFilterPill()),
                  SizedBox(height: 16),
                ],
                FiftyThirtyTwentyCard(overview: state.overview)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(
                      begin: 0.05,
                      end: 0,
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 20),
                FiftyThirtyTwentyBreakdownSection(
                  breakdown: state.breakdown,
                  overview: state.overview,
                  periodTransactions: state.periodTransactions,
                )
                    .animate()
                    .fadeIn(delay: 75.ms, duration: 350.ms)
                    .slideY(
                      begin: 0.05,
                      end: 0,
                      delay: 75.ms,
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 20),
                FiftyThirtyTwentyHistoryChart(history: state.history)
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 350.ms)
                    .slideY(
                      begin: 0.05,
                      end: 0,
                      delay: 150.ms,
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
