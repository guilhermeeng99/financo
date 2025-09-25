import 'package:app_widgets/app_widgets.dart';

class ColumnChartItem {
  const ColumnChartItem({
    required this.value,
    required this.color,
    required this.title,
    required this.index,
  });

  final double value;
  final String title;
  final Color color;
  final int index;
}

class CWColumnChart extends StatelessWidget {
  const CWColumnChart({
    required this.items,
    super.key,
    this.height = 200,
  });

  final List<ColumnChartItem> items;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(height: height);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth / (items.length * 2 + 2);

    final maxValue =
        items.map((item) => item.value.abs()).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxValue * 1.2,
          groupsSpace: 20,
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < items.length) {
                    return const Text('');
                  }
                  return const Text('');
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
          barGroups: items.map((item) {
            return BarChartGroupData(
              x: item.index,
              barRods: [
                BarChartRodData(
                  toY: item.value.abs(),
                  color: item.color,
                  width: barWidth,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
