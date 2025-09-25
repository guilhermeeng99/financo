import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

class CWAccountsResults extends StatelessWidget {
  const CWAccountsResults({required this.transactions, super.key});

  final List<TransactionI> transactions;

  @override
  Widget build(BuildContext context) {
    final totalIncome = _calculateTotalIncome();
    final totalExpense = _calculateTotalExpense();
    final totalTransfersIn = _calculateTotalTransfersIn();
    final totalTransfersOut = _calculateTotalTransfersOut();

    final totalEntries = totalIncome + totalTransfersIn;
    final totalExits = -(totalExpense + totalTransfersOut);
    final totalResult = totalEntries + totalExits;

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
        Column(
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
        ),
      ],
    );
  }

  double _calculateTotalIncome() {
    return transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == FinancialType.income,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalExpense() {
    return -transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == FinancialType.expense,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalTransfersIn() {
    return transactions
        .where(
          (transaction) => transaction.t.isTransfer && transaction.t.amount > 0,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalTransfersOut() {
    return transactions
        .where(
          (transaction) => transaction.t.isTransfer && transaction.t.amount < 0,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount.abs());
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
