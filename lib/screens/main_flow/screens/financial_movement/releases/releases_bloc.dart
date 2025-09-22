import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/index.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_filter.dart';

ReleasesBloc get releasesBloc => Modular.get<ReleasesBloc>();

class ReleasesBloc extends GetxController {
  ReleasesBloc() {
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
    ever(
      coreAccountsBloc.checkingAccounts,
      (_) => _updateCoreTransactionsBloc(),
    );
  }

  void _updateCoreTransactionsBloc() {
    coreTransactionsBloc.updateEnabledAccountIds(
      coreAccountsBloc.enabledAccountIds,
    );
  }

  Set<int> get enabledAccountIds => coreAccountsBloc.enabledAccountIds;

  List<TransactionI> get filteredTransactions =>
      coreTransactionsBloc.getFilteredTransactions(enabledAccountIds);

  void toggleFilter(TransactionFilterType filterType) {
    coreTransactionsBloc.toggleFilter(filterType);
  }

  bool isFilterActive(TransactionFilterType filterType) {
    return coreTransactionsBloc.isFilterActive(filterType);
  }
}
