import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/releases_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/releases_model.dart';

class ReleasesScreen extends StatelessWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 10),
        child: CWFloatingActionButton(
          tooltipMessage: context.t.new_transaction,
          onTap: releasesModel.onTapFloatingActionButton,
        ),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: releasesBloc.transactions.length,
          itemBuilder: (context, index) {
            final transaction = releasesBloc.transactions[index];
            return _TransactionItem(transaction: transaction);
          },
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${CurrencyFormatter.formatAmount(transaction.amount, context)}',
            ),
            Text(
              'Date: ${transaction.actualDate.formattedDateddMMyyyy(context: context)}',
            ),
            Text('Status: ${transaction.statusText}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: transaction.statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            transaction.isExpense ? context.t.expense : context.t.income,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => releasesModel.onTapTransaction(transaction),
      ),
    );
  }
}
