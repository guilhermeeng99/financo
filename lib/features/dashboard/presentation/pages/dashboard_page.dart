import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/balance_card.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/transaction_tile.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
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
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoAppBar(title: t.dashboard.title),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingShimmer();
          }
          if (state is DashboardError) {
            return ErrorView(
              message: state.failure.message,
              onRetry: () => context.read<DashboardBloc>().add(
                const DashboardLoadRequested(forceRefresh: true),
              ),
            );
          }
          if (state is DashboardLoaded) {
            return _DashboardContent(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => context.push(AppRoutes.addTransaction),
        child: const FaIcon(FontAwesomeIcons.plus),
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
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BalanceCard(
            label: t.dashboard.totalBalance,
            amount: summary.totalBalance,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: t.dashboard.income,
                  amount: summary.totalIncome,
                  color: context.appColors.income,
                  icon: FontAwesomeIcons.arrowUp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: t.dashboard.expenses,
                  amount: summary.totalExpenses,
                  color: context.appColors.expense,
                  icon: FontAwesomeIcons.arrowDown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.dashboard.recentTransactions,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.transactions),
                child: Text(t.dashboard.seeAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.recentTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  t.dashboard.noTransactionsYet,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...state.recentTransactions.map(
              (t) => TransactionTile(
                transaction: t,
                onTap: () => context.push(AppRoutes.transactionById(t.id)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(icon, color: color, size: 18),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(amount),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
