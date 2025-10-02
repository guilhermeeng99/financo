import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_service.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_types.dart';

class CWAPastAndFutureReleasesAccountsResults extends StatelessWidget {
  const CWAPastAndFutureReleasesAccountsResults({
    required this.type,
    super.key,
  });

  final PastAndFutureReleasesType type;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final results = pastAndFutureReleasesBloc.getCalculationResults(type);

      return CWCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: [
              Text(
                context.t.past_and_future_releases.period_result,
                style: const TextStyle(fontSize: 14),
              ),
              const Gap(15),
              _ResultsList(results: results),
            ],
          ),
        ),
      );
    });
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results});

  final PastAndFutureReleasesCalculationResults results;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        _ResultsItem(
          title: context.t.common.labels.entries,
          value: results.totalEntries,
          padding: const EdgeInsets.only(left: 10),
        ),
        const Gap(5),
        _ResultsItem(
          title: context.t.common.labels.exits,
          value: results.totalExits,
          padding: const EdgeInsets.only(left: 10),
        ),
        const Gap(5),
        _ResultsItem(
          title: context.t.common.labels.result(n: 1),
          value: results.totalResult,
          padding: const EdgeInsets.only(left: 10),
          isBold: true,
        ),
      ],
    );
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
