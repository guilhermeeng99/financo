import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/releases_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/releases_model.dart';
import 'package:financo/screens/main_flow/screens/releases/widgets/releases_item_menu_actions.dart.dart';

class ReleasesScreen extends StatelessWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 10),
        child: CWFloatingActionButton(
          tooltipMessage: context.t.transactions.new_transaction,
          onTap: releasesModel.onTapFloatingActionButton,
        ),
      ),
      body: Obx(
        () => ListView.separated(
          itemCount: releasesBloc.transactions.length + 2,
          separatorBuilder: (context, index) =>
              const CWDivider(width: double.infinity, height: 1),
          itemBuilder: (context, index) {
            if (index == 0 || index == releasesBloc.transactions.length + 1) {
              return const SizedBox.shrink();
            }
            final transaction = releasesBloc.transactions[index - 1];
            return _TransactionItem(transaction: transaction);
          },
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final TransactionI transaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CWCard(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 10,
            ),
            child: Row(
              spacing: 20,
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: transaction.t.paymentStatus.getColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  transaction.t.actualDate.formattedDateddMMyyyy(
                    context: context,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    if (transaction.t.description.isNotEmpty)
                      Text(
                        transaction.t.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    Row(
                      children: [
                        _TransactionItemContainer(transaction.accountName),
                        _TransactionItemContainer(transaction.categoryName),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Row(
                    spacing: 10,
                    children: [
                      if (transaction.t.paymentStatus ==
                          TransactionPaymentStatus.paid)
                        const Icon(Icons.done_all, size: 20),
                      if (transaction.t.recurrenceType ==
                          TransactionRecurrenceType.fixed)
                        const Icon(Icons.restart_alt, size: 20),
                      const Spacer(),
                      Text(
                        CurrencyFormatter.formatAmount(
                          transaction.t.amount,
                          context,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: transaction.t.amount.getColor(context),
                        ),
                      ),
                      CWPopupMenuButton<TransactionData, TransactionMenuAction>(
                        item: transaction.t,
                        actions: TransactionMenuAction.values,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionItemContainer extends StatelessWidget {
  const _TransactionItemContainer(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(title, style: const TextStyle(fontSize: 14)),
    );
  }
}
