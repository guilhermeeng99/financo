import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_filter.dart';
import 'package:app_database/app_database.dart';

FilteredReleasesBloc get filteredReleasesBloc =>
    Modular.get<FilteredReleasesBloc>();

class FilteredReleasesBloc extends GetxController {
  FilteredReleasesBloc() {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Update transactions filter when accounts change
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
  // Custom method for filtered releases that applies account filter only to pending and unpaid transactions
  List<TransactionI> getFilteredTransactions() {
    final allTransactions = transactionsFilterBloc.filteredTransactionsFilter;
    final targetAccountIds = coreAccountsBloc.enabledAccountIds;

    return allTransactions.where((transaction) {
      // Apply account filter only for pending and unpaid transactions
      final isPendingOrUnpaid =
          TransactionFilterType.pending.matchesTransaction(transaction) ||
          TransactionFilterType.unpaid.matchesTransaction(transaction);

      if (isPendingOrUnpaid) {
        return targetAccountIds.contains(transaction.t.accountId);
      }

      // For paid transactions, don't apply account filter
      return true;
    }).toList();
  }

  // Delegated methods for account management
  Future<void> loadCheckingAccounts() =>
      coreAccountsBloc.loadCheckingAccounts();
  Future<void> updateFilteredBalances() =>
      coreAccountsBloc.updateFilteredBalances();
}
