import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/item_menu_actions.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_model.dart';

class CWTransactionsTable extends StatelessWidget {
  const CWTransactionsTable({
    super.key,
    this.accountIds,
    this.customTransactions,
  });

  final Set<int>? accountIds;
  final List<TransactionI>? customTransactions;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CWCard(
        child: customTransactions != null
            ? _buildContent(context, customTransactions!)
            : Obx(() {
                final transactions = transactionsFilterBloc
                    .getFilteredTransactions(accountIds);
                return _buildContent(context, transactions);
              }),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TransactionI> transactions) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t.common.actions.filter,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              InkWell(
                onTap: () => transactionsModelExcel
                    .onTapDownloadUserTransactions(context, transactions),
                child: const Icon(Icons.download),
              ),
            ],
          ),
        ),
        const CWDivider(width: double.infinity, height: 1),
        Expanded(
          child: transactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.separated(
                  itemCount: transactions.length + 2,
                  separatorBuilder: (context, index) =>
                      const CWDivider(width: double.infinity, height: 1),
                  itemBuilder: (context, index) {
                    if (index == 0 || index == transactions.length + 1) {
                      return const SizedBox.shrink();
                    }
                    final transaction = transactions[index - 1];
                    return _TransactionItem(transaction: transaction);
                  },
                ),
        ),
      ],
    );
  }
}

class _TransactionItem<T extends PopupMenuAction<DataTransaction>>
    extends StatelessWidget {
  const _TransactionItem({required this.transaction, this.menuActions});

  final TransactionI transaction;
  final List<T>? menuActions;

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
                    color: transaction.t.paymentStatus.getColor(
                      context,
                      transaction: transaction.t,
                    ),
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
                    if (transaction.t.description != null &&
                        transaction.t.description!.isNotEmpty)
                      Text(
                        transaction.t.description!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    Row(
                      spacing: 10,
                      children: [
                        _TransactionItemContainer(transaction.accountName),
                        _TransactionItemContainer(
                          transaction.t.isTransfer
                              ? (transaction.otherAccount ??
                                    context.t.transactions.unknown_transfer)
                              : (transaction.categoryName ??
                                    context.t.categories.no_category),
                        ),
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
                      CWAmoutValue(value: transaction.t.amount),
                      CWPopupMenuButton<DataTransaction, TransactionMenuAction>(
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
