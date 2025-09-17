import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_filter.dart';

TransactionsFilterBloc get transactionsFilterBloc =>
    Modular.get<TransactionsFilterBloc>();

class TransactionsFilterBloc extends GetxController {
  TransactionsFilterBloc() {
    loadTransactions();
    ever(calendarFilterBloc.selected, (_) => loadTransactions());
    ever(activeFilters, (_) => _recalculateFilteredTransactions());
  }

  final RxSet<int> enabledAccountIds = <int>{}.obs;

  final RxList<TransactionI> transactions = <TransactionI>[].obs;
  final RxList<TransactionI> filteredTransactionsFilter = <TransactionI>[].obs;

  final RxSet<TransactionFilterType> activeFilters = <TransactionFilterType>{
    TransactionFilterType.pending,
    TransactionFilterType.unpaid,
    TransactionFilterType.paid,
  }.obs;

  Future<void> loadTransactions() async {
    final transactionUsecase = Modular.get<ITransactionUsecase>();

    try {
      final result = await transactionUsecase.getTransactionsWithDetails(
        startDate: calendarFilterBloc.startOfPeriod,
        endDate: calendarFilterBloc.endOfPeriod,
      );

      result.fold(
        (Failure failure) {
          logger.e('Error loading transactions: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        },
        (List<TransactionI> transactionsList) {
          transactions.value = transactionsList;
          logger.i(
            'TransactionsFilter loaded from database: ${transactionsList.length} items',
          );
          _recalculateFilteredTransactions();
        },
      );
    } catch (e) {
      logger.e('❌ Error loading transactions: $e');
    }
  }

  void updateEnabledAccountIds(Set<int> accountIds) {
    enabledAccountIds
      ..clear()
      ..addAll(accountIds);
  }

  List<TransactionI> getFilteredTransactions(Set<int>? accountIds) {
    final targetAccountIds = accountIds ?? enabledAccountIds.toSet();

    return filteredTransactionsFilter
        .where(
          (transaction) => targetAccountIds.contains(transaction.t.accountId),
        )
        .toList();
  }

  void _recalculateFilteredTransactions() {
    if (activeFilters.isEmpty) {
      filteredTransactionsFilter.value = [];
      return;
    }

    filteredTransactionsFilter.value = transactions.where((transaction) {
      return activeFilters.any(
        (filter) => filter.matchesTransaction(transaction),
      );
    }).toList();
  }

  void toggleFilter(TransactionFilterType filterType) {
    if (activeFilters.contains(filterType)) {
      activeFilters.remove(filterType);
    } else {
      activeFilters.add(filterType);
    }
  }

  bool isFilterActive(TransactionFilterType filterType) {
    return activeFilters.contains(filterType);
  }

  @override
  void onClose() {
    transactions.close();
    filteredTransactionsFilter.close();
    activeFilters.close();
    enabledAccountIds.close();
    super.onClose();
  }
}
