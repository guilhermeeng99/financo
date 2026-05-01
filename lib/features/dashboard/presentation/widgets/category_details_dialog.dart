import 'dart:async';

import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final _dayMonthFormat = DateFormat('dd/MM');
const double _mobileBreakpoint = 600;

String _percentLabel(double amount, double total) =>
    '${(amount / total * 100).toStringAsFixed(0)}%';

/// Opens the per-category drill-down dialog. Two tabs: list of period
/// transactions belonging to the parent (or any of its subcategories), and
/// a subcategory breakdown chart.
///
/// CategoriesCubit and AccountsCubit are scoped to the shell route below
/// MaterialApp; `showDialog` mounts under the root navigator above that
/// scope, so we capture the instances here and re-provide inside the
/// dialog.
void showCategoryDetailsDialog({
  required BuildContext context,
  required CategoryAmount parent,
  required double totalExpenses,
  required List<TransactionEntity> periodTransactions,
}) {
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
    final colors = context.appColors;
    final categoryMap = {
      for (final c in context.watch<CategoriesCubit>().state.categoriesOrEmpty)
        c.id: c,
    };
    final accountMap = {
      for (final a in context.watch<AccountsCubit>().state.accountsOrEmpty)
        a.id: a,
    };

    final categoryTransactions =
        widget.periodTransactions
            .where((t) => _belongsToParent(t, categoryMap))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final percentage = widget.totalExpenses > 0
        ? widget.parent.amount / widget.totalExpenses * 100
        : 0.0;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(widget.parent.categoryColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.parent.categoryName} '
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: FaIcon(
                      FontAwesomeIcons.xmark,
                      size: 16,
                      color: colors.onBackgroundLight,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              dividerColor: colors.surfaceVariant,
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
          AmountText(amount: -transaction.amount, fontSize: 14),
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
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            _CategoryDonut(data: data, total: total)
          else
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
          for (var i = 0; i < data.length; i++)
            _SubcategoryListRow(
              entry: data[i],
              total: total,
            ),
          const Divider(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.dashboard.totalExpenses,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AmountText(amount: -total, fontSize: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubcategoryListRow extends StatelessWidget {
  const _SubcategoryListRow({required this.entry, required this.total});

  final CategoryAmount entry;
  final double total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = total > 0 ? (entry.amount / total) * 100 : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Color(entry.categoryColor),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            entry.categoryName,
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 6),
          Text(
            '(${percent.toStringAsFixed(0)}%)',
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          AmountText(amount: -entry.amount, fontSize: 12),
        ],
      ),
    );
  }
}

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
                        ? _percentLabel(data[i].amount, total)
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
