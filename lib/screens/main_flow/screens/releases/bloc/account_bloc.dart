import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/date_bloc.dart';

class TransactionsAccountsI {
  TransactionsAccountsI({
    required this.a,
    required this.finalBalance,
    required this.finalProjectedBalance,
    bool isEnabled = true,
  }) : isEnabled = isEnabled.obs,
       filteredBalance = finalBalance.obs,
       filteredProjectedBalance = finalProjectedBalance.obs;

  final AccountData a;
  final double finalBalance;
  final double finalProjectedBalance;
  final RxBool isEnabled;
  final RxDouble filteredBalance;
  final RxDouble filteredProjectedBalance;
}

TransactionsAccountsBloc get transactionsAccountsBloc =>
    Modular.get<TransactionsAccountsBloc>();

class TransactionsAccountsBloc extends GetxController {
  TransactionsAccountsBloc() {
    loadCheckingAccounts();
    ever(dateFilterBloc.selected, (_) => updateFilteredBalances());
    ever(checkingAccounts, (_) => _updateTotalFromFilteredBalances());
  }

  final RxList<TransactionsAccountsI> checkingAccounts =
      <TransactionsAccountsI>[].obs;
  final RxDouble totalFilteredBalance = 0.0.obs;
  final RxDouble totalFilteredProjectedBalance = 0.0.obs;

  Future<void> loadCheckingAccounts() async {
    final accountUsecase = Modular.get<IAccountUsecase>();

    try {
      final result = await accountUsecase.getCheckingAccounts();

      await result.fold(
        (failure) {
          logger.e('Error loading checking accounts: ${failure.message}');
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        },
        (checkingAccountsList) async {
          final accountsI = <TransactionsAccountsI>[];

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

          final finalProjectedBalancesResult = await transactionUsecase
              .getMultipleAccountsBalanceForPeriod(
                accountIds,
                DateTime(1900),
                DateTime.now(),
                onlyPaidTransactions: false,
              );

          final finalProjectedBalances = finalProjectedBalancesResult.fold(
            (Failure failure) => <int, double>{},
            (Map<int, double> balances) => balances,
          );

          for (final account in checkingAccountsList) {
            final finalBalance =
                finalBalances[account.id] ?? account.initialBalance;
            final finalProjectedBalance =
                finalProjectedBalances[account.id] ?? account.initialBalance;
            final accountI = TransactionsAccountsI(
              a: account,
              finalBalance: finalBalance,
              finalProjectedBalance: finalProjectedBalance,
            );
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
    final endOfPeriod = dateFilterBloc.endOfPeriod;

    try {
      if (checkingAccounts.isEmpty) return;

      final accountIds = checkingAccounts.map((a) => a.a.id).toSet();

      final balancesResult = await transactionUsecase
          .getMultipleAccountsBalanceForPeriod(
            accountIds,
            DateTime(1900),
            endOfPeriod,
          );

      final balances = balancesResult.fold((Failure failure) {
        logger.e('Error updating filtered balances: ${failure.message}');
        return <int, double>{};
      }, (Map<int, double> balances) => balances);

      final projectedBalancesResult = await transactionUsecase
          .getMultipleAccountsBalanceForPeriod(
            accountIds,
            DateTime(1900),
            endOfPeriod,
            onlyPaidTransactions: false,
          );

      final projectedBalances = projectedBalancesResult.fold((Failure failure) {
        logger.e('Error updating projected balances: ${failure.message}');
        return <int, double>{};
      }, (Map<int, double> balances) => balances);

      double total = 0;
      double totalProjected = 0;

      for (final account in checkingAccounts) {
        final filteredBalance =
            balances[account.a.id] ?? account.a.initialBalance;
        final filteredProjectedBalance =
            projectedBalances[account.a.id] ?? account.a.initialBalance;

        account.filteredBalance.value = filteredBalance;
        account.filteredProjectedBalance.value = filteredProjectedBalance;

        if (account.isEnabled.value) {
          total += filteredBalance;
          totalProjected += filteredProjectedBalance;
        }
      }

      totalFilteredBalance.value = total;
      totalFilteredProjectedBalance.value = totalProjected;
    } catch (e) {
      logger.e('❌ Error updating filtered balances: $e');
    }
  }

  void _updateTotalFromFilteredBalances() {
    double total = 0;
    double totalProjected = 0;
    for (final account in checkingAccounts) {
      if (account.isEnabled.value) {
        total += account.filteredBalance.value;
        totalProjected += account.filteredProjectedBalance.value;
      }
    }
    totalFilteredBalance.value = total;
    totalFilteredProjectedBalance.value = totalProjected;
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
    final endOfPeriod = DateTime(
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
          DateTime(1900),
          endOfPeriod,
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
    final endOfPeriod = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
      23,
      59,
      59,
    );

    final balanceResult = await transactionUsecase.getAccountBalanceForPeriod(
      accountId,
      DateTime(1900),
      endOfPeriod,
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
