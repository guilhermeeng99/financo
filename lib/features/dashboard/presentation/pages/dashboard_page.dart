import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final filter = context.read<DateFilterCubit>().state;
    context.read<DashboardBloc>().add(
      DashboardLoadRequested(year: filter.year, month: filter.month),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DateFilterCubit, DateFilterState>(
      listener: (context, filter) {
        context.read<DashboardBloc>().add(
          DashboardLoadRequested(
            year: filter.year,
            month: filter.month,
            forceRefresh: true,
          ),
        );
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingShimmer();
          }
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Saldo das contas ──────────────────────────────
          _SectionTitle(title: t.dashboard.accountBalances),
          const SizedBox(height: 8),
          _AccountsTable(summary: summary, colors: colors),
          const SizedBox(height: 24),

          // ─── Resultado do mês ──────────────────────────────
          _SectionTitle(title: t.dashboard.monthResult),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  label: t.dashboard.income,
                  amount: summary.totalIncome,
                  color: colors.income,
                  icon: FontAwesomeIcons.arrowUp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultCard(
                  label: t.dashboard.expenses,
                  amount: -summary.totalExpenses,
                  color: colors.expense,
                  icon: FontAwesomeIcons.arrowDown,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultCard(
                  label: t.dashboard.netResult,
                  amount: summary.netResult,
                  color: summary.netResult >= 0
                      ? colors.income
                      : colors.expense,
                  icon: summary.netResult >= 0
                      ? FontAwesomeIcons.chartLine
                      : FontAwesomeIcons.triangleExclamation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Despesas por categoria (bar chart) ────────────
          _SectionTitle(title: t.dashboard.expensesByCategory),
          const SizedBox(height: 8),
          _ExpensesBarChart(
            data: summary.expensesByCategory,
            colors: colors,
          ),
          const SizedBox(height: 24),

          // ─── Receitas por categoria (donut chart) ──────────
          _SectionTitle(title: t.dashboard.incomeByCategory),
          const SizedBox(height: 8),
          _IncomeDonutChart(
            data: summary.incomeByCategory,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

// ─── Section title ──────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// ─── Accounts table ─────────────────────────────────────────
class _AccountsTable extends StatelessWidget {
  const _AccountsTable({required this.summary, required this.colors});
  final DashboardSummary summary;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    if (summary.accounts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              t.dashboard.noAccountsYet,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.appColors.onBackgroundLight,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...summary.accounts.map(
              (account) => InkWell(
                onTap: () => context.go(AppRoutes.accountById(account.id)),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          account.name,
                          style: context.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AmountText(
                        amount: account.initialBalance,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.dashboard.totalBalance,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AmountText(
                  amount: summary.totalBalance,
                  fontSize: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Result card ────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  const _ResultCard({
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(icon, color: color, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.appColors.onBackgroundLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AmountText(
                amount: amount,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expenses bar chart ─────────────────────────────────────
class _ExpensesBarChart extends StatelessWidget {
  const _ExpensesBarChart({required this.data, required this.colors});
  final List<CategoryAmount> data;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChartCard(message: t.dashboard.noExpensesYet);
    }

    final maxAmount = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final total = data.fold<double>(0, (s, e) => s + e.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: data.length * 48.0 + 16,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount * 1.15,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIdx, rod, rodIdx) {
                        return BarTooltipItem(
                          '${data[group.x].categoryName}\n',
                          context.textTheme.labelSmall!,
                          children: [
                            TextSpan(
                              text: formatCurrency(data[group.x].amount),
                              style: context.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _truncate(data[idx].categoryName, 8),
                              style: context.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(data.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].amount,
                          color: Color(data[i].categoryColor),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const Divider(height: 24),
            _CategoryList(
              data: data,
              total: total,
              totalLabel: t.dashboard.totalExpenses,
            ),
          ],
        ),
      ),
    );
  }

  String _truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}…' : s;
}

// ─── Income donut chart ─────────────────────────────────────
class _IncomeDonutChart extends StatelessWidget {
  const _IncomeDonutChart({required this.data, required this.colors});
  final List<CategoryAmount> data;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChartCard(message: t.dashboard.noIncomeYet);
    }

    final total = data.fold<double>(0, (s, e) => s + e.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 44,
                        sections: data.map((item) {
                          final pct = item.amount / total * 100;
                          return PieChartSectionData(
                            value: item.amount,
                            color: Color(item.categoryColor),
                            radius: 44,
                            title: '${pct.toStringAsFixed(0)}%',
                            titleStyle: context.textTheme.labelSmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Color(item.categoryColor),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.categoryName,
                                  style: context.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            _CategoryList(
              data: data,
              total: total,
              totalLabel: t.dashboard.totalIncome,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category list with total ────────────────────────────────
class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.data,
    required this.total,
    required this.totalLabel,
  });

  final List<CategoryAmount> data;
  final double total;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...data.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(item.categoryColor),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.categoryName,
                    style: context.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AmountText(
                  amount: item.amount,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              totalLabel,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AmountText(
              amount: total,
              fontSize: 11,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Empty chart placeholder ────────────────────────────────
class _EmptyChartCard extends StatelessWidget {
  const _EmptyChartCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.appColors.onBackgroundLight,
            ),
          ),
        ),
      ),
    );
  }
}
