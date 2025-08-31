import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/date_bloc.dart';

class AccountI {
  AccountI({required this.a, required this.finalBalance, bool isEnabled = true})
    : isEnabled = isEnabled.obs,
      filteredBalance = finalBalance.obs;

  final AccountData a;
  final double finalBalance;
  final RxBool isEnabled;
  final RxDouble filteredBalance;
}

AccountsBloc get accountsBloc => Modular.get<AccountsBloc>();

class AccountsBloc extends GetxController {
  AccountsBloc() {
    loadCheckingAccounts();
    ever(dateFilterBloc.selectedDate, (_) => updateFilteredBalances());
    ever(checkingAccounts, (_) => _updateTotalFromFilteredBalances());
  }

  final RxList<AccountI> checkingAccounts = <AccountI>[].obs;
  final RxDouble totalFilteredBalance = 0.0.obs;

  Future<void> loadCheckingAccounts() async {
    final accountUsecase = Modular.get<AccountUsecase>();

    try {
      final result = await accountUsecase.getCheckingAccounts();

      await result.fold(
        (failure) {
          logger.e('Error loading checking accounts: ${failure.message}');
          AppWidgetsUtils.snackBar(
            title: failure.message,
            type: SnackBarType.error,
          );
        },
        (checkingAccountsList) async {
          final accountsI = <AccountI>[];

          final accountIds = checkingAccountsList.map((a) => a.id).toSet();
          final transactionUsecase = Modular.get<ITransactionUsecase>();

          final finalBalancesResult = await transactionUsecase
              .getMultipleAccountsBalanceForPeriod(
                accountIds,
                DateTime(1900),
                DateTime.now(),
              );

          final finalBalances = finalBalancesResult.fold(
            (Failure failure) => <int, double>{},
            (Map<int, double> balances) => balances,
          );

          for (final account in checkingAccountsList) {
            final finalBalance =
                finalBalances[account.id] ?? account.initialBalance;
            final accountI = AccountI(a: account, finalBalance: finalBalance);
            accountsI.add(accountI);
          }

          checkingAccounts.value = accountsI;

          for (final account in checkingAccounts) {
            ever(account.isEnabled, (_) => _updateTotalFromFilteredBalances());
          }

          logger.i('Checking accounts loaded from database');
          await updateFilteredBalances();
        },
      );
    } catch (e) {
      logger.e('❌ Error loading checking accounts: $e');
    }
  }

  Future<void> updateFilteredBalances() async {
    final transactionUsecase = Modular.get<ITransactionUsecase>();
    final startOfMonth = dateFilterBloc.startOfMonth;
    final endOfMonth = dateFilterBloc.endOfMonth;

    try {
      if (checkingAccounts.isEmpty) return;

      final accountIds = checkingAccounts.map((a) => a.a.id).toSet();

      final balancesResult = await transactionUsecase
          .getMultipleAccountsBalanceForPeriod(
            accountIds,
            startOfMonth,
            endOfMonth,
          );

      final balances = balancesResult.fold((Failure failure) {
        logger.e('Error updating filtered balances: ${failure.message}');
        return <int, double>{};
      }, (Map<int, double> balances) => balances);

      double total = 0;
      for (final account in checkingAccounts) {
        final filteredBalance =
            balances[account.a.id] ?? account.a.initialBalance;
        account.filteredBalance.value = filteredBalance;

        if (account.isEnabled.value) {
          total += filteredBalance;
        }
      }

      totalFilteredBalance.value = total;
    } catch (e) {
      logger.e('❌ Error updating filtered balances: $e');
    }
  }

  void _updateTotalFromFilteredBalances() {
    double total = 0;
    for (final account in checkingAccounts) {
      if (account.isEnabled.value) {
        total += account.filteredBalance.value;
      }
    }
    totalFilteredBalance.value = total;
  }

  double get totalEnabledAccountsBalance {
    return checkingAccounts
        .where((account) => account.isEnabled.value)
        .fold(0, (sum, account) => sum + account.finalBalance);
  }

  Future<double> getTotalEnabledAccountsBalanceForDate(
    DateTime selectedDate,
  ) async {
    if (checkingAccounts.isEmpty) return 0;

    final enabledAccountIds = checkingAccounts
        .where((a) => a.isEnabled.value)
        .map((a) => a.a.id)
        .toSet();

    final transactionUsecase = Modular.get<ITransactionUsecase>();
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month);
    final endOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
      23,
      59,
      59,
    );

    final balancesResult = await transactionUsecase
        .getMultipleAccountsBalanceForPeriod(
          enabledAccountIds,
          startOfMonth,
          endOfMonth,
        );

    return balancesResult.fold(
      (Failure failure) => 0.0,
      (Map<int, double> balances) => balances.values.fold<double>(
        0,
        (double sum, double balance) => sum + balance,
      ),
    );
  }

  Future<double> getAccountBalanceForDate(
    int accountId,
    DateTime selectedDate,
  ) async {
    final transactionUsecase = Modular.get<ITransactionUsecase>();
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month);
    final endOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
      23,
      59,
      59,
    );

    final balanceResult = await transactionUsecase.getAccountBalanceForPeriod(
      accountId,
      startOfMonth,
      endOfMonth,
    );

    return balanceResult.fold(
      (Failure failure) => 0,
      (double balance) => balance,
    );
  }

  Set<int> get enabledAccountIds {
    return checkingAccounts
        .where((account) => account.isEnabled.value)
        .map((account) => account.a.id)
        .toSet();
  }

  @override
  void onClose() {
    checkingAccounts.close();
    totalFilteredBalance.close();
    super.onClose();
  }
}
