import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/features/budgets/domain/entities/budget_overview.dart';
import 'package:financo/features/budgets/presentation/cubit/budgets_cubit.dart';
import 'package:financo/features/budgets/presentation/widgets/budget_tile.dart';
import 'package:financo/features/budgets/presentation/widgets/budgets_empty_state.dart';
import 'package:financo/features/budgets/presentation/widgets/budgets_summary_card.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<BudgetsCubit>().loadBudgets());
  }

  Future<void> _openAdd() async {
    final result = await context.push<bool>(AppRoutes.addBudget);
    if (result == true && mounted) {
      unawaited(
        context.read<BudgetsCubit>().loadBudgets(forceRefresh: true),
      );
    }
  }

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.general.delete),
        content: Text(t.budgets.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.general.delete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<BudgetsCubit>().deleteBudget(overview.budget.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.budgets.budgetDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(title: t.budgets.title),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'budgets_fab',
          onPressed: _openAdd,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: BlocBuilder<BudgetsCubit, BudgetsState>(
        builder: (context, state) {
          if (state is BudgetsLoading || state is BudgetsInitial) {
            return const LoadingShimmer();
          }
          if (state is BudgetsError) {
            return ErrorView(
              message: state.failure.message,
              onRetry: () => context
                  .read<BudgetsCubit>()
                  .loadBudgets(forceRefresh: true),
            );
          }
          if (state is BudgetsLoaded) {
            if (state.overviews.isEmpty) {
              return BudgetsEmptyState(onAddPressed: _openAdd);
            }
            return _BudgetsBody(
              state: state,
              onTap: _openEdit,
              onDelete: _confirmDelete,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BudgetsBody extends StatelessWidget {
  const _BudgetsBody({
    required this.state,
    required this.onTap,
    required this.onDelete,
  });

  final BudgetsLoaded state;
  final void Function(BudgetOverview) onTap;
  final void Function(BudgetOverview) onDelete;

  @override
  Widget build(BuildContext context) {
    // 96px bottom padding clears the floating bottom nav + FAB so the
    // last tile doesn't tuck underneath them.
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
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
