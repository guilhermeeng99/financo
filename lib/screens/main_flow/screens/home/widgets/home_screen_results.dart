import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/home/home_bloc.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_container.dart';

class CWHomeScreenAccountsResults extends StatelessWidget {
  const CWHomeScreenAccountsResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return HomeScreenContainer(
        title:
            '${context.t.overview.result_of_the_month} (${context.t.overview.projected_situation})',
        bottomChild: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: _ResultsItem(
            title: context.t.common.labels.result(n: 1),
            value: homeBloc.totalResult,
            padding: const EdgeInsets.only(left: 10),
            isBold: true,
          ),
        ),
        child: Column(
          spacing: 15,
          children: [
            const _ColumnChart(),
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
          _ContainerItem(
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

class _ContainerItem extends StatelessWidget {
  const _ContainerItem({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      width: 100,
      child: child,
    );
  }
}

class _ColumnChart extends StatelessWidget {
  const _ColumnChart();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth / 8;

    return Obx(() {
      return SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY:
                [
                  homeBloc.totalEntries,
                  homeBloc.totalExits,
                ].reduce((a, b) => a.abs() > b.abs() ? a : b).abs() *
                1.2,
            barTouchData: const BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    switch (value.toInt()) {
                      default:
                        return const Text('');
                    }
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: homeBloc.totalEntries,
                    color: Theme.of(context).customColors.income,
                    width: barWidth,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: homeBloc.totalExits.abs(),
                    color: Theme.of(context).customColors.expense,
                    width: barWidth,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
