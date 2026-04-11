import 'dart:async';

import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) {
        final cubit = ReportsCubit(
          getTransactions: GetIt.I<GetTransactionsUseCase>(),
          userId: userId,
        );
        unawaited(cubit.loadReports());
        return cubit;
      },
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoAppBar(title: t.reports.title),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) return const LoadingShimmer();
          if (state is ReportsError) {
            return ErrorView(
              message: state.failure.message,
              onRetry: () => context.read<ReportsCubit>().loadReports(),
            );
          }
          if (state is ReportsLoaded) {
            return _ReportsContent(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent({required this.state});

  final ReportsLoaded state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCards(state: state),
        const SizedBox(height: 24),
        Text(
          t.reports.incomeVsExpenses,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _BarChart(state: state),
        ),
        const SizedBox(height: 24),
        if (state.expensesByCategory.isNotEmpty) ...[
          Text(
            t.reports.expensesByCategory,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _PieChart(data: state.expensesByCategory),
          ),
        ],
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.state});

  final ReportsLoaded state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ReportCard(
            label: t.reports.income,
            amount: state.summary.totalIncome,
            color: context.appColors.income,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ReportCard(
            label: t.reports.expenses,
            amount: state.summary.totalExpenses,
            color: context.appColors.expense,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ReportCard(
            label: t.reports.net,
            amount: state.summary.netResult,
            color: state.summary.netResult >= 0
                ? context.appColors.income
                : context.appColors.expense,
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatCurrency(amount),
              style: context.textTheme.titleSmall?.copyWith(
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

class _BarChart extends StatelessWidget {
  const _BarChart({required this.state});

  final ReportsLoaded state;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            [
              state.summary.totalIncome,
              state.summary.totalExpenses,
            ].reduce((a, b) => a > b ? a : b) *
            1.2,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return Text(t.reports.income);
                  case 1:
                    return Text(t.reports.expenses);
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: state.summary.totalIncome,
                color: context.appColors.income,
                width: 32,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: state.summary.totalExpenses,
                color: context.appColors.expense,
                width: 32,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.data});

  final Map<String, double> data;

  static const _colors = [
    Color(0xFF1A2B4A),
    Color(0xFF4A7CC9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (s, v) => s + v);
    var i = 0;
    return PieChart(
      PieChartData(
        sections: data.entries.map((entry) {
          final color = _colors[i % _colors.length];
          i++;
          return PieChartSectionData(
            value: entry.value,
            title: '${(entry.value / total * 100).toStringAsFixed(0)}%',
            color: color,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}
