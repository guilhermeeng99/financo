import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/account_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/date_bloc.dart';

TransactionsBloc get transactionsBloc => Modular.get<TransactionsBloc>();

class TransactionsBloc extends GetxController {
  TransactionsBloc() {
    loadTransactions();
    ever(dateFilterBloc.selected, (_) => loadTransactions());
    ever(transactionsAccountsBloc.checkingAccounts, (_) => _calculateResults());
    ever(transactions, (_) => _calculateResults());
  }

  final RxList<TransactionI> transactions = <TransactionI>[].obs;
  final RxDouble projectedTotalIncome = 0.0.obs;
  final RxDouble projectedTotalExpense = 0.0.obs;
  final RxDouble projectedTotalTransfers = 0.0.obs;

  Future<void> loadTransactions() async {
    final transactionUsecase = Modular.get<ITransactionUsecase>();

    try {
      final result = await transactionUsecase.getTransactionsWithDetails(
        startDate: dateFilterBloc.startOfPeriod,
        endDate: dateFilterBloc.endOfPeriod,
      );

      result.fold(
        (Failure failure) {
          logger.e('Error loading transactions: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        },
        (List<TransactionI> transactionsList) {
          transactions.value = transactionsList;
          logger
            ..i(
              'Transactions loaded from database: ${transactionsList.length} items',
            )
            ..i(
              'Date range: ${dateFilterBloc.startOfPeriod} to ${dateFilterBloc.endOfPeriod}',
            );
          _calculateResults();
        },
      );
    } catch (e) {
      logger.e('❌ Error loading transactions: $e');
    }
  }

  Future<void> _calculateResults() async {
    final enabledAccountIds = transactionsAccountsBloc.enabledAccountIds;

    if (enabledAccountIds.isEmpty) {
      projectedTotalIncome.value = 0.0;
      projectedTotalExpense.value = 0.0;
      projectedTotalTransfers.value = 0.0;
      return;
    }

    final transactionUsecase = Modular.get<ITransactionUsecase>();

    try {
      final result = await transactionUsecase.getTransactionSummary(
        accountIds: enabledAccountIds,
        startDate: dateFilterBloc.startOfPeriod,
        endDate: dateFilterBloc.endOfPeriod,
      );

      result.fold(
        (Failure failure) {
          logger.e('Error calculating transaction summary: ${failure.message}');
        },
        (TransactionSummary summary) {
          projectedTotalIncome.value = summary.projectedTotalIncome;
          projectedTotalExpense.value = summary.projectedTotalExpense;
          projectedTotalTransfers.value = summary.projectedTotalTransfers;
        },
      );
    } catch (e) {
      logger.e('❌ Error calculating transaction summary: $e');
    }
  }

  List<TransactionI> getFilteredTransactions(Set<int> enabledAccountIds) {
    return transactions
        .where(
          (transaction) => enabledAccountIds.contains(transaction.t.accountId),
        )
        .toList();
  }

  double get projectedTotalResult =>
      projectedTotalIncome.value - projectedTotalExpense.value;

  @override
  void onClose() {
    transactions.close();
    projectedTotalIncome.close();
    projectedTotalExpense.close();
    projectedTotalTransfers.close();
    super.onClose();
  }
}
