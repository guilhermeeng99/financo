import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/transaction_account_data.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/credit_card/credit_card_service.dart';

CreditCardBloc get creditCardBloc => Modular.get<CreditCardBloc>();

class CreditCardBloc extends GetxController {
  CreditCardBloc() {
    _resetFilters();
    _initializeListeners();
    _handleRouteParameters();
  }

  bool _accountSelectedFromUrl = false;

  CreditCardService get _creditCardService =>
      CreditCardService(filteredTransactions);

  void _resetFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      coreTransactionsBloc.resetFilters();
      coreAccountsBloc.enableAllAccounts();
      coreCalendarBloc.resetDate();
    });
  }

  void _initializeListeners() {
    ever(coreAccountsBloc.creditCardAccounts, (_) {
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
      ever(coreAccountsBloc.creditCardAccounts, (_) {
        if (accounts.any((acc) => acc.account.id == accountId)) {
          selectAccount(accountId);
          _accountSelectedFromUrl = true;
        }
      });
    }
  }

  void _updateCoreTransactionsBloc() {
    coreTransactionsBloc.updateEnabledAccountIds(
      coreAccountsBloc.enabledCreditCardAccountIds,
    );
  }

  Set<int> get enabledAccountIds =>
      coreAccountsBloc.enabledCreditCardAccountIds;

  List<TransactionI> get filteredTransactions =>
      coreTransactionsBloc.getFilteredTransactions(enabledAccountIds);

  List<TransactionsAccount> get accounts => coreAccountsBloc.creditCardAccounts;

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

  CreditCardBillDates? get currentBillDates {
    if (!hasValidSelection) return null;

    final account = getAccountById(selectedAccountId);
    final billClosingDay = account.account.billClosingDay ?? 1;
    final now = DateTime.now();

    return _creditCardService.calculateBillDates(
      currentDate: now,
      billClosingDay: billClosingDay,
      firstBillDueDate: account.account.firstBillDueDate,
    );
  }

  CreditCardBillCalculationResults? get currentBillResults {
    final billDates = currentBillDates;
    if (billDates == null) return null;

    final account = getAccountById(selectedAccountId);
    final creditLimit = account.account.creditLimit;

    return _creditCardService.calculateBillResults(
      billDates.closingDate,
      creditLimit,
    );
  }
}
