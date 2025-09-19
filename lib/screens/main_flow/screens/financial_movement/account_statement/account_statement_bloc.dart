import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';

AccountStatementBloc get accountStatementBloc =>
    Modular.get<AccountStatementBloc>();

class AccountStatementBloc extends GetxController {
  AccountStatementBloc() {
    _resetFilters();
    _initializeListeners();
  }

  void _resetFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      coreTransactionsBloc.resetFilters();
      coreAccountsBloc.enableAllAccounts();
      coreCalendarBloc.resetDate();
    });
  }

  void _initializeListeners() {
    ever(coreAccountsBloc.checkingAccounts, (_) {
      _updateCoreTransactionsBloc();
      // Ensure single account selection after accounts are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ensureSingleAccountSelected();
      });
    });
  }

  void _updateCoreTransactionsBloc() {
    coreTransactionsBloc.updateEnabledAccountIds(
      coreAccountsBloc.enabledAccountIds,
    );
  }

  Set<int> get enabledAccountIds => coreAccountsBloc.enabledAccountIds;

  List<TransactionI> get filteredTransactions =>
      coreTransactionsBloc.getFilteredTransactions(enabledAccountIds);

  List<TransactionsAccount> get accounts => coreAccountsBloc.checkingAccounts;

  int get selectedAccountId {
    final enabledAccounts = accounts
        .where((acc) => acc.isEnabled.value)
        .toList();

    if (enabledAccounts.length == 1) {
      return enabledAccounts.first.account.id;
    }

    if (enabledAccounts.isEmpty && accounts.isNotEmpty) {
      return accounts.first.account.id;
    }

    return enabledAccounts.isNotEmpty ? enabledAccounts.first.account.id : 0;
  }

  bool get hasValidSelection {
    final enabledAccounts = accounts
        .where((acc) => acc.isEnabled.value)
        .toList();
    return enabledAccounts.length == 1;
  }

  void ensureSingleAccountSelected() {
    if (!hasValidSelection && accounts.isNotEmpty) {
      selectAccount(accounts.first.account.id);
    }
  }

  List<int> get dropdownItems {
    return accounts.map((account) => account.account.id).toList();
  }

  void selectAccount(int accountId) {
    for (final account in accounts) {
      account.isEnabled.value = account.account.id == accountId;
    }
  }

  TransactionsAccount getAccountById(int accountId) {
    return accounts.firstWhere((acc) => acc.account.id == accountId);
  }
}
