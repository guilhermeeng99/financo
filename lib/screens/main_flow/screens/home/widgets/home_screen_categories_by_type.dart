import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/home/home_bloc.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_container.dart';

class CWHomeScreenCategoriesByType extends StatelessWidget {
  const CWHomeScreenCategoriesByType({required this.financialType, super.key});

  final FinancialType financialType;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final transactionsByCategory = homeBloc.getSortedTransactionsByCategory(
        financialType,
      );
      final total = homeBloc.getTotalByType(financialType);

      final titleKey = financialType == FinancialType.expense
          ? context.t.overview.expense_by_category
          : context.t.overview.income_by_category;

      return HomeScreenContainer(
        title: titleKey,
        subTitle: ' (${context.t.overview.projected_situation})',
        bottomChild: _Total(total: total),
        child: transactionsByCategory.isEmpty
            ? Center(
                child: Text(
                  context.t.transactions.no_transactions_found,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            : Column(
                spacing: 10,
                children: [
                  CWColumnChart(
                    items: transactionsByCategory
                        .take(5)
                        .map(
                          (entry) => ColumnChartItem(
                            title: entry.key,
                            value: entry.value,
                            color: _getCategoryColor(
                              context,
                              transactionsByCategory.indexOf(entry),
                            ),
                            index: transactionsByCategory.indexOf(entry),
                          ),
                        )
                        .toList(),
                  ),
                  ...transactionsByCategory.map(
                    (entry) => _CategoryItem(
                      categoryName: entry.key,
                      value: entry.value,
                      total: total,
                      color: _getCategoryColor(
                        context,
                        transactionsByCategory.indexOf(entry),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }

  Color _getCategoryColor(BuildContext context, int index) {
    final colors = [
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lime,
      Colors.brown,
      Colors.blueGrey,
      Colors.deepPurple,
      Colors.green,
      Colors.red,
      Colors.blue,
      Colors.yellow,
      const Color(0xFF8E24AA),
      const Color(0xFF00ACC1),
      const Color(0xFF43A047),
      const Color(0xFFFF7043),
      const Color(0xFF1E88E5),
      const Color(0xFF6D4C41),
      const Color(0xFF5E35B1),
      const Color(0xFF546E7A),
      const Color(0xFFFFB300),
      const Color(0xFFE53935),
    ];

    final finalColors = financialType == FinancialType.expense
        ? colors.reversed.toList()
        : colors;

    return finalColors[index % finalColors.length];
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.categoryName,
    required this.value,
    required this.total,
    required this.color,
  });

  final String categoryName;
  final double value;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percentage = total.abs() > 0
        ? (value.abs() / total.abs() * 100)
        : 0.0;

    return Row(
      spacing: 10,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(categoryName, style: const TextStyle(fontSize: 14)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 11),
          ),
        ),
        const Spacer(),
        CWContainerAmoutValue(child: CWAmoutValue(value: value, fontSize: 14)),
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.t.common.labels.total,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          CWContainerAmoutValue(
            child: CWAmoutValue(
              value: total,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
