import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_filter.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_types.dart';

PastAndFutureReleasesBloc get pastAndFutureReleasesBloc =>
    Modular.get<PastAndFutureReleasesBloc>();

class PastAndFutureReleasesBloc extends GetxController {
  PastAndFutureReleasesBloc() {
    _initializeListeners();
  }

  void _initializeListeners() {
    ever(
      coreAccountsBloc.checkingAccounts,
      (_) => _updateTransactionsFilterBloc(),
    );
  }

  void _updateTransactionsFilterBloc() {
    transactionsFilterBloc.updateEnabledAccountIds(
      coreAccountsBloc.enabledAccountIds,
    );
  }

  List<TransactionI> getFilteredTransactions(
    PastAndFutureReleasesScreenType type,
  ) {
    final allTransactions = transactionsFilterBloc.filteredTransactionsFilter;
    final targetAccountIds = coreAccountsBloc.enabledAccountIds;
    final allowedFilters = type.allowedFilters;

    return allTransactions.where((transaction) {
      final matchesTypeFilter = allowedFilters.any(
        (filter) => filter.matchesTransaction(transaction),
      );

      if (matchesTypeFilter) {
        return targetAccountIds.contains(transaction.t.accountId);
      }

      return false;
    }).toList();
  }

  Future<void> loadCheckingAccounts() =>
      coreAccountsBloc.loadCheckingAccounts();
  Future<void> updateFilteredBalances() =>
      coreAccountsBloc.updateFilteredBalances();
}
