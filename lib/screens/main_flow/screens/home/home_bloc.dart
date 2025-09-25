import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/home/home_service.dart';

HomeBloc get homeBloc => Modular.get<HomeBloc>();

class HomeBloc extends GetxController {
  HomeBloc() {
    _resetFilters();
  }

  void _resetFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      coreTransactionsBloc.resetFilters();
      coreAccountsBloc.enableAllAccounts();
      coreCalendarBloc.resetDate();
    });
  }

  void navigateToPrevious() {
    coreCalendarBloc.navigateToPrevious();
  }

  void navigateToNext() {
    coreCalendarBloc.navigateToNext();
  }

  String getFormattedPeriod({
    required BuildContext context,
    bool short = false,
  }) {
    return coreCalendarBloc.getFormattedPeriod(context: context, short: short);
  }

  Set<int> get enabledAccountIds => coreAccountsBloc.enabledAccountIds;

  List<TransactionI> get filteredTransactions =>
      coreTransactionsBloc.getFilteredTransactions(enabledAccountIds);

  Set<int> get allAccountIds =>
      checkingAccounts.map((account) => account.account.id).toSet();

  List<TransactionI> get allTransactionsWithoutTransfers => coreTransactionsBloc
      .getFilteredTransactions(allAccountIds)
      .where((transaction) => !transaction.t.isTransfer)
      .toList();

  RxList<TransactionsAccount> get checkingAccounts =>
      coreAccountsBloc.checkingAccounts;

  Rx<double> get totalAllAccountsBalance =>
      coreAccountsBloc.totalAllAccountsBalance;

  Rx<double> get totalAllAccountsProjectedBalance =>
      coreAccountsBloc.totalAllAccountsProjectedBalance;

  bool get areAllAccountsEnabled {
    return checkingAccounts.every((account) => account.isEnabled.value);
  }

  void toggleAllAccounts() {
    final shouldEnable = !areAllAccountsEnabled;
    for (final account in checkingAccounts) {
      account.isEnabled.value = shouldEnable;
    }
  }

  void enableAllAccounts() {
    coreAccountsBloc.enableAllAccounts();
  }

  double get totalEntries => HomeCalculationsService.calculateTotalIncome(
    allTransactionsWithoutTransfers,
  );
  double get totalExits => HomeCalculationsService.calculateTotalExpense(
    allTransactionsWithoutTransfers,
  );

  double get totalResult => totalEntries + totalExits;

  List<MapEntry<String, double>> getSortedTransactionsByCategory(
    FinancialType financialType,
  ) {
    return HomeCalculationsService.getSortedTransactionsByCategory(
      financialType,
      allTransactionsWithoutTransfers,
    );
  }

  double getTotalByType(FinancialType financialType) {
    return HomeCalculationsService.getTotalByType(
      financialType,
      allTransactionsWithoutTransfers,
    );
  }
}
