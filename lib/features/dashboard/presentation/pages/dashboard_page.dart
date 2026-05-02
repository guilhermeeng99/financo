import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/dashboard/presentation/cubit/dashboard_account_selection_cubit.dart';
import 'package:financo/features/dashboard/presentation/widgets/category_breakdown_list.dart';
import 'package:financo/features/dashboard/presentation/widgets/category_details_dialog.dart';
import 'package:financo/features/dashboard/presentation/widgets/dashboard_account_row.dart';
import 'package:financo/features/dashboard/presentation/widgets/dashboard_hero.dart';
import 'package:financo/features/dashboard/presentation/widgets/dashboard_section.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    final filter = context.read<DateFilterCubit>().state;
    context.read<DashboardBloc>().add(
      DashboardLoadRequested(year: filter.year, month: filter.month),
    );
  }

  Future<void> _openAddTransaction() async {
    await context.push(AppRoutes.addTransaction);
    if (!mounted) return;
    final filter = context.read<DateFilterCubit>().state;
    context.read<DashboardBloc>().add(
      DashboardLoadRequested(
        year: filter.year,
        month: filter.month,
        forceRefresh: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'dashboard_fab',
          onPressed: _openAddTransaction,
          tooltip: t.transactions.addTransaction,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DateFilterCubit, DateFilterState>(
            listener: (context, filter) {
              context.read<DashboardBloc>().add(
                DashboardLoadRequested(
                  year: filter.year,
                  month: filter.month,
                  forceRefresh: true,
                ),
              );
            },
          ),
          BlocListener<AccountsCubit, AccountsState>(
            // Refresh whenever accounts data lands (initial load or post-CSV
            // import) — both states carry the up-to-date list.
            listenWhen: (previous, current) =>
                current is AccountsLoaded || current is AccountsImported,
            listener: (context, state) {
              final filter = context.read<DateFilterCubit>().state;
              context.read<DashboardBloc>().add(
                DashboardLoadRequested(
                  year: filter.year,
                  month: filter.month,
                  forceRefresh: true,
                ),
              );
            },
          ),
        ],
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) return const LoadingShimmer();
            if (state is DashboardError) {
              return ErrorView(
                message: state.failure.message,
                onRetry: () => context.read<DashboardBloc>().add(
                  DashboardLoadRequested(forceRefresh: true),
                ),
              );
            }
            if (state is DashboardLoaded) {
              return _DashboardContent(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final DashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final colors = context.appColors;

    // Sorted by displayed balance (descending) so the user sees the
    // most relevant accounts at the top of each section. For credit
    // cards, "biggest" = closest to zero, since their balance trends
    // negative as the user spends.
    final checking = (summary.accounts
            .where((a) => a.type == AccountType.checking)
            .toList())
      ..sort((a, b) => b.initialBalance.compareTo(a.initialBalance));
    final creditCards = (summary.accounts
            .where((a) => a.type == AccountType.creditCard)
            .toList())
      ..sort((a, b) => b.initialBalance.compareTo(a.initialBalance));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        DashboardHero(
          income: summary.totalIncome,
          expenses: summary.totalExpenses,
          netResult: summary.netResult,
        ).animate().fadeIn(duration: 400.ms).slideY(
              begin: 0.05,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
        if (checking.isNotEmpty) ...[
          const SizedBox(height: 24),
          DashboardSection(
            label: t.dashboard.accountBalances,
            count: checking.length,
            accent: colors.primary,
            child: _CheckingList(accounts: checking),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(
                begin: 0.05,
                end: 0,
                delay: 100.ms,
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
        ],
        if (creditCards.isNotEmpty) ...[
          const SizedBox(height: 20),
          DashboardSection(
            label: t.dashboard.creditCardBalance,
            count: creditCards.length,
            accent: colors.warning,
            child: _AccountList(accounts: creditCards),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(
                begin: 0.05,
                end: 0,
                delay: 150.ms,
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
        ],
        if (checking.isEmpty && creditCards.isEmpty) ...[
          const SizedBox(height: 24),
          _NoAccountsHint(),
        ],
        const SizedBox(height: 20),
        DashboardSection(
          label: t.dashboard.expensesByCategory,
          accent: colors.expense,
          child: summary.expensesByCategory.isEmpty
              ? _EmptyHint(message: t.dashboard.noExpensesYet)
              : CategoryBreakdownList(
                  data: summary.expensesByCategory,
                  isExpense: true,
                  onCategoryTap: (category) => showCategoryDetailsDialog(
                    context: context,
                    parent: category,
                    totalExpenses: summary.totalExpenses,
                    periodTransactions: state.periodTransactions,
                  ),
                ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(
              begin: 0.05,
              end: 0,
              delay: 200.ms,
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 20),
        DashboardSection(
          label: t.dashboard.incomeByCategory,
          accent: colors.income,
          child: summary.incomeByCategory.isEmpty
              ? _EmptyHint(message: t.dashboard.noIncomeYet)
              : CategoryBreakdownList(
                  data: summary.incomeByCategory,
                  isExpense: false,
                ),
        )
            .animate()
            .fadeIn(delay: 250.ms, duration: 400.ms)
            .slideY(
              begin: 0.05,
              end: 0,
              delay: 250.ms,
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
      ],
    );
  }
}

class _AccountList extends StatelessWidget {
  const _AccountList({required this.accounts});

  final List<AccountEntity> accounts;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        for (var i = 0; i < accounts.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(height: 0.5, color: colors.surfaceVariant),
            ),
          DashboardAccountRow(
            account: accounts[i],
            onTap: () =>
                context.go(AppRoutes.accountById(accounts[i].id)),
          ),
        ],
      ],
    );
  }
}

/// Account list for the **checking** section. Adds a per-row checkbox
/// that controls whether the account is summed into the trailing
/// "Total" row. Selection state is owned by
/// [DashboardAccountSelectionCubit] so it survives navigation and app
/// restarts.
class _CheckingList extends StatelessWidget {
  const _CheckingList({required this.accounts});

  final List<AccountEntity> accounts;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<
      DashboardAccountSelectionCubit,
      DashboardAccountSelectionState
    >(
      builder: (context, selection) {
        final cubit = context.read<DashboardAccountSelectionCubit>();
        final total = accounts
            .where((a) => !selection.excludedIds.contains(a.id))
            .fold<double>(0, (sum, a) => sum + a.initialBalance);
        return Column(
          children: [
            for (var i = 0; i < accounts.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(height: 0.5, color: colors.surfaceVariant),
                ),
              DashboardAccountRow(
                account: accounts[i],
                includedInTotal:
                    !selection.excludedIds.contains(accounts[i].id),
                onToggleIncluded: () => cubit.toggle(accounts[i].id),
                onTap: () =>
                    context.go(AppRoutes.accountById(accounts[i].id)),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(height: 0.5, color: colors.surfaceVariant),
            ),
            _TotalRow(amount: total),
          ],
        );
      },
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Match the horizontal rhythm of the account rows above:
    //   [outer 8] [label] ... [amount] [6] [chevron-shaped 11] [outer 8]
    // The trailing 11px placeholder mirrors the chevron icon so the
    // amount's right edge lines up with the rows' amount column.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              t.dashboard.totalBalance,
              style: context.textTheme.labelMedium?.copyWith(
                color: colors.onBackgroundLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(amount),
            style: context.textTheme.titleMedium?.copyWith(
              color: amount >= 0 ? colors.income : colors.expense,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          const SizedBox(width: 11),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}

class _NoAccountsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.buildingColumns,
                size: 18,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.dashboard.noAccountsYet,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.accounts.emptySubtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onBackgroundLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
