import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/accounts_bloc.dart';

class CWAccountsResults extends StatelessWidget {
  const CWAccountsResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: CWDivider(height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                context.t.common.labels.result(n: 2),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Expanded(child: CWDivider(height: 1)),
          ],
        ),
        const Gap(15),
        Obx(() {
          final totalIncome = coreAccountsBloc.projectedTotalIncome.value;
          final totalExpense = coreAccountsBloc.projectedTotalExpense.value;
          final totalTransfersIn =
              coreAccountsBloc.projectedTotalTransfersIn.value;
          final totalTransfersOut =
              coreAccountsBloc.projectedTotalTransfersOut.value;

          final totalEntries = totalIncome + totalTransfersIn;
          final totalExits = -(totalExpense + totalTransfersOut);
          final totalResult = totalEntries + totalExits;

          return Column(
            spacing: 5,
            children: [
              _ResultsItem(
                title: context.t.common.labels.entries,
                value: totalEntries,
                padding: const EdgeInsets.only(left: 10),
              ),
              _ResultsItem(
                title: context.t.transactions.types.income,
                value: totalIncome,
              ),
              _ResultsItem(
                title: context.t.common.labels.transfers(n: 2),
                value: totalTransfersIn,
              ),
              const Gap(5),
              _ResultsItem(
                title: context.t.common.labels.exits,
                value: totalExits,
                padding: const EdgeInsets.only(left: 10),
              ),
              _ResultsItem(
                title: context.t.transactions.types.expense,
                value: -totalExpense,
              ),
              _ResultsItem(
                title: context.t.common.labels.transfers(n: 2),
                value: -totalTransfersOut,
              ),
              const Gap(5),
              _ResultsItem(
                title: context.t.common.labels.result(n: 1),
                value: totalResult,
                padding: const EdgeInsets.only(left: 10),
                isBold: true,
              ),
            ],
          );
        }),
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
