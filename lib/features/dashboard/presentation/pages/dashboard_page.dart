import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    return MultiBlocListener(
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
          listener: (context, state) {
            if (state is AccountsLoaded) {
              final filter = context.read<DateFilterCubit>().state;
              context.read<DashboardBloc>().add(
                DashboardLoadRequested(
                  year: filter.year,
                  month: filter.month,
                  forceRefresh: true,
                ),
              );
            }
          },
        ),
      ],
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

    final checkingAccounts = summary.accounts
        .where((a) => a.type == AccountType.checking)
        .toList();
    final creditCardAccounts = summary.accounts
        .where((a) => a.type == AccountType.creditCard)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Saldo das contas correntes ────────────────────
          _SectionTitle(title: t.dashboard.accountBalances),
          const SizedBox(height: 8),
          _AccountsTable(
            accounts: checkingAccounts,
            emptyMessage: t.dashboard.noAccountsYet,
          ),
          const SizedBox(height: 24),

          // ─── Saldo dos cartões de crédito ──────────────────
          _SectionTitle(title: t.dashboard.creditCardBalance),
          const SizedBox(height: 8),
          _AccountsTable(
            accounts: creditCardAccounts,
            emptyMessage: t.dashboard.noCreditCardsYet,
          ),
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
            onCategoryTap: (category) => _showCategoryDetailsDialog(
              context: context,
              parent: category,
              totalExpenses: summary.totalExpenses,
              periodTransactions: state.periodTransactions,
            ),
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
  const _AccountsTable({
    required this.accounts,
    required this.emptyMessage,
  });

  final List<AccountEntity> accounts;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              emptyMessage,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.appColors.onBackgroundLight,
              ),
            ),
          ),
        ),
      );
    }

    final total = accounts.fold<double>(
      0,
      (sum, a) => sum + a.initialBalance,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...accounts.map(
              (account) => InkWell(
                onTap: () => context.go(
                  AppRoutes.accountById(account.id),
                ),
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
                  amount: total,
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

// ─── Mobile breakpoint ──────────────────────────────────────
const double _mobileBreakpoint = 600;

// ─── Category donut (mobile) ────────────────────────────────
class _CategoryDonut extends StatelessWidget {
  const _CategoryDonut({required this.data, required this.total});

  final List<CategoryAmount> data;
  final double total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: SizedBox(
          height: 180,
          width: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 44,
              sections: [
                for (var i = 0; i < data.length; i++)
                  PieChartSectionData(
                    value: data[i].amount,
                    color: Color(data[i].categoryColor),
                    radius: 44,
                    title: total > 0
                        ? '${(data[i].amount / total * 100).toStringAsFixed(0)}%'
                        : '',
                    titleStyle: context.textTheme.labelSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Expenses bar chart ─────────────────────────────────────
class _ExpensesBarChart extends StatelessWidget {
  const _ExpensesBarChart({
    required this.data,
    required this.colors,
    this.onCategoryTap,
  });
  final List<CategoryAmount> data;
  final dynamic colors;
  final void Function(CategoryAmount)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyChartCard(message: t.dashboard.noExpensesYet);
    }

    final maxAmount = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final total = data.fold<double>(0, (s, e) => s + e.amount);
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile)
              _CategoryDonut(data: data, total: total)
            else
              SizedBox(
                height: 200,
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
                    titlesData: const FlTitlesData(
                      bottomTitles: AxisTitles(),
                      leftTitles: AxisTitles(),
                      rightTitles: AxisTitles(),
                      topTitles: AxisTitles(),
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
                            width: 100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
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
              isExpense: true,
              showPercentage: true,
              onCategoryTap: onCategoryTap,
            ),
          ],
        ),
      ),
    );
  }
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
                        sections: _buildSections(context, total),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < data.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      data[i].categoryColor,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    data[i].categoryName,
                                    style: context.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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

  List<PieChartSectionData> _buildSections(
    BuildContext context,
    double total,
  ) {
    return [
      for (var i = 0; i < data.length; i++)
        PieChartSectionData(
          value: data[i].amount,
          color: Color(data[i].categoryColor),
          radius: 44,
          title: '${(data[i].amount / total * 100).toStringAsFixed(0)}%',
          titleStyle: context.textTheme.labelSmall!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
    ];
  }
}

// ─── Category list with total ────────────────────────────────
class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.data,
    required this.total,
    required this.totalLabel,
    this.isExpense = false,
    this.showPercentage = false,
    this.onCategoryTap,
  });

  final List<CategoryAmount> data;
  final double total;
  final String totalLabel;
  final bool isExpense;
  final bool showPercentage;
  final void Function(CategoryAmount)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < data.length; i++)
          InkWell(
            onTap: onCategoryTap == null ? null : () => onCategoryTap!(data[i]),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(data[i].categoryColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data[i].categoryName,
                    style: context.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 5),
                  if (showPercentage && total > 0) ...[
                    Text(
                      '(${(data[i].amount / total * 100).toStringAsFixed(0)}%)',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.appColors.onBackgroundLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Spacer(),
                  AmountText(
                    amount: isExpense ? -data[i].amount : data[i].amount,
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
              amount: isExpense ? -total : total,
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

// ─── Category details dialog ────────────────────────────────
final _dayMonthFormat = DateFormat('dd/MM');

void _showCategoryDetailsDialog({
  required BuildContext context,
  required CategoryAmount parent,
  required double totalExpenses,
  required List<TransactionEntity> periodTransactions,
}) {
  // CategoriesCubit and AccountsCubit are scoped to the shell route below
  // MaterialApp, but showDialog mounts under the root navigator above that
  // scope. Capture the instances here and re-provide them inside the dialog.
  final categoriesCubit = context.read<CategoriesCubit>();
  final accountsCubit = context.read<AccountsCubit>();

  unawaited(
    showDialog<void>(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: categoriesCubit),
          BlocProvider.value(value: accountsCubit),
        ],
        child: _CategoryDetailsDialog(
          parent: parent,
          totalExpenses: totalExpenses,
          periodTransactions: periodTransactions,
        ),
      ),
    ),
  );
}

class _CategoryDetailsDialog extends StatefulWidget {
  const _CategoryDetailsDialog({
    required this.parent,
    required this.totalExpenses,
    required this.periodTransactions,
  });

  final CategoryAmount parent;
  final double totalExpenses;
  final List<TransactionEntity> periodTransactions;

  @override
  State<_CategoryDetailsDialog> createState() => _CategoryDetailsDialogState();
}

class _CategoryDetailsDialogState extends State<_CategoryDetailsDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = context.watch<CategoriesCubit>().state;
    final categoryMap = categoriesState is CategoriesLoaded
        ? {for (final c in categoriesState.categories) c.id: c}
        : <String, CategoryEntity>{};
    final accountsState = context.watch<AccountsCubit>().state;
    final accountMap = accountsState is AccountsLoaded
        ? {for (final a in accountsState.accounts) a.id: a}
        : <String, AccountEntity>{};

    final categoryTransactions =
        widget.periodTransactions
            .where((t) => _belongsToParent(t, categoryMap))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final percentage = widget.totalExpenses > 0
        ? widget.parent.amount / widget.totalExpenses * 100
        : 0.0;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.parent.categoryName} '
                      '(${percentage.toStringAsFixed(2)}%)',
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: t.dashboard.transactionList),
                Tab(text: t.dashboard.subcategories),
              ],
            ),
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CategoryTransactionsTab(
                    transactions: categoryTransactions,
                    categoryMap: categoryMap,
                    accountMap: accountMap,
                  ),
                  _SubcategoriesTab(
                    parent: widget.parent,
                    transactions: categoryTransactions,
                    categoryMap: categoryMap,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.dashboard.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _belongsToParent(
    TransactionEntity tx,
    Map<String, CategoryEntity> categoryMap,
  ) {
    if (tx.isTransfer) return false;
    if (tx.type != TransactionType.expense) return false;
    if (tx.categoryId == widget.parent.categoryId) return true;
    final cat = categoryMap[tx.categoryId];
    return cat?.parentId == widget.parent.categoryId;
  }
}

// ─── Tab 1: transactions list ───────────────────────────────
class _CategoryTransactionsTab extends StatelessWidget {
  const _CategoryTransactionsTab({
    required this.transactions,
    required this.categoryMap,
    required this.accountMap,
  });

  final List<TransactionEntity> transactions;
  final Map<String, CategoryEntity> categoryMap;
  final Map<String, AccountEntity> accountMap;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            t.dashboard.noExpensesYet,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.appColors.onBackgroundLight,
            ),
          ),
        ),
      );
    }

    final total = transactions.fold<double>(0, (s, t) => s + t.amount);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: transactions.length + 1,
      itemBuilder: (context, index) {
        if (index == transactions.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.dashboard.total,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AmountText(amount: -total, fontSize: 14),
              ],
            ),
          );
        }
        final tx = transactions[index];
        final cat = categoryMap[tx.categoryId];
        final account = accountMap[tx.accountId];
        return _CategoryTransactionRow(
          transaction: tx,
          dotColor: cat != null
              ? Color(cat.color)
              : context.appColors.onBackgroundLight,
          accountName: account?.name,
        );
      },
    );
  }
}

class _CategoryTransactionRow extends StatelessWidget {
  const _CategoryTransactionRow({
    required this.transaction,
    required this.dotColor,
    required this.accountName,
  });

  final TransactionEntity transaction;
  final Color dotColor;
  final String? accountName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _dayMonthFormat.format(transaction.date),
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.description.isNotEmpty)
                  Text(
                    transaction.description,
                    style: context.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (accountName != null) ...[
                  if (transaction.description.isNotEmpty)
                    const SizedBox(height: 4),
                  _AccountChip(name: accountName!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          AmountText(
            amount: -transaction.amount,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.onBackgroundLight.withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.creditCard,
            size: 10,
            color: colors.onBackgroundLight,
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 2: subcategories ───────────────────────────────────
class _SubcategoriesTab extends StatelessWidget {
  const _SubcategoriesTab({
    required this.parent,
    required this.transactions,
    required this.categoryMap,
  });

  final CategoryAmount parent;
  final List<TransactionEntity> transactions;
  final Map<String, CategoryEntity> categoryMap;

  @override
  Widget build(BuildContext context) {
    // Aggregate by categoryId — only true subcategories (skip transactions
    // booked directly on the parent).
    final amounts = <String, double>{};
    for (final tx in transactions) {
      if (tx.categoryId == parent.categoryId) continue;
      amounts[tx.categoryId] = (amounts[tx.categoryId] ?? 0) + tx.amount;
    }

    final data = amounts.entries.map((e) {
      final cat = categoryMap[e.key];
      return CategoryAmount(
        categoryId: e.key,
        categoryName: cat?.name ?? 'Sem categoria',
        categoryColor: cat?.color ?? 0xFF9E9E9E,
        amount: e.value,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            t.dashboard.noSubcategories,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.appColors.onBackgroundLight,
            ),
          ),
        ),
      );
    }

    final maxAmount = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final total = data.fold<double>(0, (s, e) => s + e.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
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
                titlesData: const FlTitlesData(
                  bottomTitles: AxisTitles(),
                  leftTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
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
                        width: 80,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
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
            isExpense: true,
            showPercentage: true,
          ),
        ],
      ),
    );
  }
}
