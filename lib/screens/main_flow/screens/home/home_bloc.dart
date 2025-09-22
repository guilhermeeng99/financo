import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';

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

  RxList<TransactionsAccount> get checkingAccounts =>
      coreAccountsBloc.checkingAccounts;

  Rx<double> get totalAllAccountsBalance =>
      coreAccountsBloc.totalAllAccountsBalance;

  Rx<double> get totalAllAccountsProjectedBalance =>
      coreAccountsBloc.totalAllAccountsProjectedBalance;

  double get totalIncome => _calculateTotalIncome(filteredTransactions);
  double get totalExpense => _calculateTotalExpense(filteredTransactions);
  double get totalTransfersIn =>
      _calculateTotalTransfersIn(filteredTransactions);
  double get totalTransfersOut =>
      _calculateTotalTransfersOut(filteredTransactions);

  double get totalEntries => totalIncome + totalTransfersIn;
  double get totalExits => -(totalExpense + totalTransfersOut);
  double get totalResult => totalEntries + totalExits;

  double _calculateTotalIncome(List<TransactionI> transactions) {
    return transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == FinancialType.income,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalExpense(List<TransactionI> transactions) {
    return -transactions
        .where(
          (transaction) =>
              transaction.t.transactionType == FinancialType.expense,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalTransfersIn(List<TransactionI> transactions) {
    return transactions
        .where(
          (transaction) => transaction.t.isTransfer && transaction.t.amount > 0,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount);
  }

  double _calculateTotalTransfersOut(List<TransactionI> transactions) {
    return transactions
        .where(
          (transaction) => transaction.t.isTransfer && transaction.t.amount < 0,
        )
        .fold(0, (sum, transaction) => sum + transaction.t.amount.abs());
  }

  bool get areAllAccountsEnabled {
    return checkingAccounts.every((account) => account.isEnabled.value);
  }

  void toggleAllAccounts() {
    final shouldEnable = !areAllAccountsEnabled;
    for (final account in checkingAccounts) {
      account.isEnabled.value = shouldEnable;
    }
  }
}
