import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/date_bloc.dart';

TransactionsBloc get transactionsBloc => Modular.get<TransactionsBloc>();

class TransactionsBloc extends GetxController {
  TransactionsBloc() {
    loadTransactions();
    ever(dateFilterBloc.selectedDate, (_) => loadTransactions());
  }

  final RxList<TransactionI> transactions = <TransactionI>[].obs;

  Future<void> loadTransactions() async {
    final transactionUsecase = Modular.get<ITransactionUsecase>();

    try {
      final result = await transactionUsecase.getTransactionsWithDetails(
        startDate: dateFilterBloc.startOfMonth,
        endDate: dateFilterBloc.endOfMonth,
      );

      result.fold(
        (Failure failure) {
          logger.e('Error loading transactions: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        },
        (List<TransactionI> transactionsList) {
          transactions.value = transactionsList;
          logger.i(
            'Transactions loaded from database: ${transactionsList.length} items',
          );
        },
      );
    } catch (e) {
      logger.e('❌ Error loading transactions: $e');
    }
  }

  List<TransactionI> getFilteredTransactions(Set<int> enabledAccountIds) {
    return transactions
        .where(
          (transaction) => enabledAccountIds.contains(transaction.t.accountId),
        )
        .toList();
  }

  @override
  void onClose() {
    transactions.close();
    super.onClose();
  }
}
