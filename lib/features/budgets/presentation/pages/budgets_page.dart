import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_month_filter_pill.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/responsive_layout.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/budgets/domain/entities/budget_overview.dart';
import 'package:financo/features/budgets/presentation/cubit/budgets_cubit.dart';
import 'package:financo/features/budgets/presentation/widgets/budget_tile.dart';
import 'package:financo/features/budgets/presentation/widgets/budgets_csv_import_dialog.dart';
import 'package:financo/features/budgets/presentation/widgets/budgets_summary_card.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key, this.embedded = false});

  /// When `true`, the page is rendered as a sub-tab of a parent shell
  /// (e.g. `PlanningPage`). The internal `Scaffold` skips its own
  /// `FinancoLargeAppBar` so the parent's app bar can host the title
  /// + page-level actions instead. The FAB and CSV-import action
  /// surface as a floating affordance at the bottom-right of the body.
  final bool embedded;

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  @override
  void initState() {
    super.initState();
    // Read the global filter once so the very first load lands on the
    // user's currently-selected month (the listener below keeps it in
    // sync after that).
    unawaited(
      Future.microtask(() {
        if (!mounted) return;
        final filter = context.read<DateFilterCubit>().state;
        unawaited(
          context.read<BudgetsCubit>().loadBudgets(
            month: DateTime(filter.year, filter.month),
          ),
        );
      }),
    );
  }

  Future<void> _openAdd() async {
    final result = await context.push<bool>(AppRoutes.addBudget);
    if (result == true && mounted) {
      unawaited(
        context.read<BudgetsCubit>().loadBudgets(forceRefresh: true),
      );
    }
  }

  Future<void> _openImport() => showBudgetsCsvImportDialog(context);

  Future<void> _openEdit(BudgetOverview overview) async {
    final result = await context.push<bool>(
      AppRoutes.editBudget,
      extra: overview.budget,
    );
    if (result == true && mounted) {
      unawaited(
        context.read<BudgetsCubit>().loadBudgets(forceRefresh: true),
      );
    }
  }

  Future<void> _confirmDelete(BudgetOverview overview) async {
    final confirmed = await showFinancoConfirmDialog(
      context,
      icon: FontAwesomeIcons.trashCan,
      title: t.general.delete,
      message: t.budgets.deleteConfirm,
      confirmLabel: t.general.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await context.read<BudgetsCubit>().deleteBudget(overview.budget.id);
    if (!mounted) return;
    context.showSnack(t.budgets.budgetDeleted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.embedded
          ? null
          : FinancoLargeAppBar(
              title: t.budgets.title,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 4),
                  child: _BudgetsAppBarIconButton(
                    icon: FontAwesomeIcons.fileArrowUp,
                    tooltip: t.budgets.importCsv,
                    color: context.appColors.primary,
                    onPressed: () => unawaited(_openImport()),
                  ),
                ),
              ],
            ),
      floatingActionButton: widget.embedded
          // Embedded mode lost its app bar (parent shell owns the
          // title row), so the "import CSV" action has nowhere to
          // live — surface it as a small secondary FAB stacked
          // above the primary "+" button.
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'budgets_import_fab',
                  onPressed: () => unawaited(_openImport()),
                  tooltip: t.budgets.importCsv,
                  child: const FaIcon(
                    FontAwesomeIcons.fileArrowUp,
                    size: 14,
                  ),
                ),
                const SizedBox(height: 12),
                LiftedFab(
                  child: FloatingActionButton(
                    heroTag: 'budgets_fab',
                    onPressed: _openAdd,
                    child: const FaIcon(FontAwesomeIcons.plus),
                  ),
                ),
              ],
            )
          : LiftedFab(
              child: FloatingActionButton(
                heroTag: 'budgets_fab',
                onPressed: _openAdd,
                child: const FaIcon(FontAwesomeIcons.plus),
              ),
            ),
      body: BlocListener<DateFilterCubit, DateFilterState>(
        // Re-fetch whenever the global month stepper moves so the user
        // can review past months' spend vs. cap. Force refresh — the
        // cubit's same-month short-circuit would otherwise no-op when
        // landing back on the original month.
        listener: (context, filter) {
          unawaited(
            context.read<BudgetsCubit>().loadBudgets(
              month: DateTime(filter.year, filter.month),
              forceRefresh: true,
            ),
          );
        },
        child: BlocBuilder<BudgetsCubit, BudgetsState>(
          builder: (context, state) {
            if (state is BudgetsLoading || state is BudgetsInitial) {
              return const LoadingShimmer();
            }
            if (state is BudgetsError) {
              return ErrorView(
                failure: state.failure,
                onRetry: () => context.read<BudgetsCubit>().loadBudgets(
                  forceRefresh: true,
                ),
              );
            }
            if (state is BudgetsLoaded) {
              if (state.overviews.isEmpty) {
                // Body + example chip pitch what budgets *do* with a
                // concrete case so first-time users get the concept.
                return FeatureEmptyState(
                  icon: FontAwesomeIcons.bullseye,
                  title: t.budgets.emptyTitle,
                  message: t.budgets.emptyBody,
                  example: t.budgets.emptyExample,
                  messageLineHeight: 1.5,
                  actionGap: 28,
                  actionLabel: t.budgets.emptyAction,
                  onAction: _openAdd,
                );
              }
              return _BudgetsBody(
                state: state,
                hasStackedFloatingActions: widget.embedded,
                onTap: _openEdit,
                onDelete: _confirmDelete,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _BudgetsBody extends StatelessWidget {
  const _BudgetsBody({
    required this.state,
    required this.hasStackedFloatingActions,
    required this.onTap,
    required this.onDelete,
  });

  final BudgetsLoaded state;
  final bool hasStackedFloatingActions;
  final void Function(BudgetOverview) onTap;
  final void Function(BudgetOverview) onDelete;

  @override
  Widget build(BuildContext context) {
    // The shell renders the sidebar at >=600px and that sidebar already
    // hosts a month stepper. On mobile the sidebar is hidden, so the
    // body has to surface the pill itself — same rule the dashboard uses.
    final isMobile = ResponsiveLayout.isMobile(context);
    final bottomPadding = floatingActionScrollEndPadding(
      hasStackedActions: isMobile && hasStackedFloatingActions,
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding),
      children: [
        if (isMobile) ...const [
          Center(child: FinancoMonthFilterPill()),
          SizedBox(height: 16),
        ],
        BudgetsSummaryCard(
          totalCap: state.totalCap,
          totalSpent: state.totalSpent,
          totalRemaining: state.totalRemaining,
        ),
        const SizedBox(height: 16),
        ...state.overviews.map(
          (o) => BudgetTile(
            overview: o,
            onTap: () => onTap(o),
            onDelete: () => onDelete(o),
          ),
        ),
      ],
    );
  }
}

class _BudgetsAppBarIconButton extends StatelessWidget {
  const _BudgetsAppBarIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final FaIconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(child: FaIcon(icon, size: 14, color: color)),
          ),
        ),
      ),
    );
  }
}
