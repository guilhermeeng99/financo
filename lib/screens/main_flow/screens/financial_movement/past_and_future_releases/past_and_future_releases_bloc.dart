import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_filter.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_service.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_types.dart';

PastAndFutureReleasesBloc get pastAndFutureReleasesBloc =>
    Modular.get<PastAndFutureReleasesBloc>();

class PastAndFutureReleasesBloc extends GetxController {
  PastAndFutureReleasesBloc() {
    _initializeListeners();
  }

  final Rx<FinancialType> _selectedFinancialType = Rx<FinancialType>(
    FinancialType.expense,
  );
  FinancialType get selectedFinancialType => _selectedFinancialType.value;

  void setFinancialTypeFilter(FinancialType type) {
    if (_selectedFinancialType.value != type) {
      _selectedFinancialType.value = type;
      update();
    }
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
    PastAndFutureReleasesType type, {
    int? accountId,
    bool includeAllTypes = false,
  }) {
    final allTransactions = transactionsFilterBloc.filteredTransactionsFilter;
    final targetAccountIds = accountId != null
        ? [accountId]
        : coreAccountsBloc.enabledAccountIds;
    final allowedFilters = type.allowedFilters;

    return allTransactions.where((transaction) {
      final matchesTypeFilter = allowedFilters.any(
        (filter) => filter.matchesTransaction(transaction),
      );

      if (matchesTypeFilter) {
        final matchesAccount = targetAccountIds.contains(
          transaction.t.accountId,
        );

        if (includeAllTypes) {
          return matchesAccount;
        }

        final matchesFinancialType =
            transaction.t.transactionType == _selectedFinancialType.value;
        return matchesAccount && matchesFinancialType;
      }

      return false;
    }).toList();
  }

  List<PastAndFutureReleasesAccountCalculationResult> getAccountCalculations(
    PastAndFutureReleasesType type,
  ) {
    final checkingAccounts = coreAccountsBloc.checkingAccounts;
    const calculator = PastAndFutureReleasesService([]);

    return checkingAccounts.map((account) {
      final transactions = getFilteredTransactions(
        type,
        accountId: account.account.id,
      );
      final calculatedBalance = calculator.calculateAccountBalance(
        transactions,
      );

      return PastAndFutureReleasesAccountCalculationResult(
        account: account,
        transactions: transactions,
        calculatedBalance: calculatedBalance,
      );
    }).toList();
  }

  PastAndFutureReleasesCalculationResults getCalculationResults(
    PastAndFutureReleasesType type,
  ) {
    final allTransactions = getFilteredTransactions(
      type,
      includeAllTypes: true,
    );
    final calculator = PastAndFutureReleasesService(allTransactions);
    return calculator.calculateResults();
  }

  double getTotalAllAccountsBalance(PastAndFutureReleasesType type) {
    return getAccountCalculations(type)
        .where((calc) => calc.account.isEnabled.value)
        .fold<double>(0, (sum, calc) => sum + calc.calculatedBalance);
  }
}
