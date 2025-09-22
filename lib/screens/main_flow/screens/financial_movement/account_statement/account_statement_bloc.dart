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
    _handleRouteParameters();
  }

  bool _accountSelectedFromUrl = false;

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ensureSingleAccountSelected();
      });
    });
  }

  void _handleRouteParameters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = Modular.args;
      final accountId = _getAccountIdFromArguments(arguments);

      if (accountId != null) {
        _selectAccountWhenAvailable(accountId);
      }
    });
  }

  int? _getAccountIdFromArguments(ModularArguments arguments) {
    if (arguments.data is Map<String, dynamic>) {
      final accountId = (arguments.data as Map<String, dynamic>)['accountId'];
      if (accountId is int) return accountId;
    }

    final queryParam = arguments.queryParams['accountId'];
    return queryParam != null ? int.tryParse(queryParam) : null;
  }

  void _selectAccountWhenAvailable(int accountId) {
    if (accounts.any((acc) => acc.account.id == accountId)) {
      selectAccount(accountId);
      _accountSelectedFromUrl = true;
    } else {
      ever(coreAccountsBloc.checkingAccounts, (_) {
        if (accounts.any((acc) => acc.account.id == accountId)) {
          selectAccount(accountId);
          _accountSelectedFromUrl = true;
        }
      });
    }
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
    if (!_accountSelectedFromUrl && !hasValidSelection && accounts.isNotEmpty) {
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
    _accountSelectedFromUrl = true;
  }

  void setInitialAccount(int accountId) {
    _selectAccountWhenAvailable(accountId);
  }

  TransactionsAccount getAccountById(int accountId) {
    return accounts.firstWhere((acc) => acc.account.id == accountId);
  }
}
