import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/home/home_bloc.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_container.dart';

class CWHomeScreenAccountsResults extends StatelessWidget {
  const CWHomeScreenAccountsResults({super.key});

  bool get isEmpty => homeBloc.allTransactionsWithoutTransfers.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return HomeScreenContainer(
        title: context.t.overview.result_of_the_month,
        subTitle: ' (${context.t.overview.projected_situation})',
        bottomChild: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: _ResultsItem(
            title: context.t.common.labels.result(n: 1),
            value: homeBloc.totalResult,
            padding: const EdgeInsets.only(left: 10),
            isBold: true,
          ),
        ),
        child: isEmpty
            ? Center(
                child: Text(
                  context.t.transactions.no_transactions_found,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            : Column(
                spacing: 15,
                children: [
                  CWColumnChart(
                    items: [
                      ColumnChartItem(
                        title: context.t.common.labels.entries,
                        value: homeBloc.totalEntries,
                        color: Theme.of(context).customColors.income,
                        index: 0,
                      ),
                      ColumnChartItem(
                        title: context.t.common.labels.exits,
                        value: homeBloc.totalExits,
                        color: Theme.of(context).customColors.expense,
                        index: 1,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).customColors.income,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: _ResultsItem(
                          title: context.t.common.labels.entries,
                          value: homeBloc.totalEntries,
                          padding: const EdgeInsets.only(left: 10),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).customColors.expense,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: _ResultsItem(
                          title: context.t.common.labels.exits,
                          value: homeBloc.totalExits,
                          padding: const EdgeInsets.only(left: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
    });
  }
}

class _ResultsItem extends StatelessWidget {
  const _ResultsItem({
    required this.title,
    required this.value,
    this.padding = const EdgeInsets.only(left: 30),
    this.isBold = false,
  });

  final String title;
  final double value;
  final EdgeInsetsGeometry padding;

  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
          CWContainerAmoutValue(
            child: CWAmoutValue(
              value: value,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
