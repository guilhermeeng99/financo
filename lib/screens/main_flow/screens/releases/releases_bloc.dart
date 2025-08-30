import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

class TransactionI {
  TransactionI({
    required this.t,
    required this.accountName,
    required this.categoryName,
  });

  final TransactionData t;
  final String accountName;
  final String categoryName;
}

TransactionsBloc get transactionsBloc => Modular.get<TransactionsBloc>();

class TransactionsBloc extends GetxController {
  TransactionsBloc() {
    loadTransactions();
  }

  final RxList<TransactionI> transactions = <TransactionI>[].obs;

  Future<void> loadTransactions() async {
    final transactionUsecase = Modular.get<TransactionUsecase>();

    try {
      final result = await transactionUsecase.getAllTransactions();

      await result.fold(
        (failure) {
          logger.e('Error loading transactions: ${failure.message}');
          AppWidgetsUtils.snackBar(
            title: failure.message,
            type: SnackBarType.error,
          );
        },
        (transactionsList) async {
          final transactionsI = <TransactionI>[];

          for (final transaction in transactionsList) {
            final accountName = await _getAccountName(transaction.accountId);
            final categoryName = await _getCategoryName(transaction.categoryId);
            transactionsI.add(
              TransactionI(
                t: transaction,
                accountName: accountName,
                categoryName: categoryName,
              ),
            );
          }

          transactions.value = transactionsI;
          logger.i('Transactions loaded from database');
        },
      );
    } catch (e) {
      logger.e('❌ Error loading transactions: $e');
    }
  }

  Future<String> _getAccountName(int accountId) async {
    final accountUsecase = Modular.get<AccountUsecase>();

    try {
      final result = await accountUsecase.getAccountById(accountId);

      return result.fold(
        (failure) {
          logger.e('Error loading account name: ${failure.message}');
          return 'Account not found';
        },
        (account) {
          if (account != null) {
            return account.name;
          } else {
            return 'Account not found';
          }
        },
      );
    } catch (e) {
      logger.e('❌ Error loading account name: $e');
      return 'Error loading account name';
    }
  }

  Future<String> _getCategoryName(int categoryId) async {
    final categoryUsecase = Modular.get<CategoryUsecase>();

    try {
      final result = await categoryUsecase.getCategoryDisplayName(categoryId);

      return result.fold((failure) {
        logger.e('Error loading category name: ${failure.message}');
        return 'Category not found';
      }, (categoryDisplayName) => categoryDisplayName);
    } catch (e) {
      logger.e('❌ Error loading category name: $e');
      return 'Error loading category name';
    }
  }

  List<TransactionI> getFilteredTransactions(Set<int> enabledAccountIds) {
    return transactions
        .where(
          (transaction) => enabledAccountIds.contains(transaction.t.accountId),
        )
        .toList();
  }

  @override
  void onClose() {
    transactions.close();
    super.onClose();
  }
}

class AccountI {
  AccountI({required this.a, required this.finalBalance, bool isEnabled = true})
    : isEnabled = isEnabled.obs;

  final AccountData a;
  final double finalBalance;
  final RxBool isEnabled;
}

AccountsBloc get accountsBloc => Modular.get<AccountsBloc>();

class AccountsBloc extends GetxController {
  AccountsBloc() {
    loadCheckingAccounts();
  }

  final RxList<AccountI> checkingAccounts = <AccountI>[].obs;

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

          for (final account in checkingAccountsList) {
            final balanceResult = await accountUsecase.getAccountFinalBalance(
              account.id,
            );

            final finalBalance = balanceResult.fold((failure) {
              logger.e(
                'Error loading final balance for account ${account.id}: ${failure.message}',
              );
              return account.initialBalance;
            }, (balance) => balance);

            accountsI.add(AccountI(a: account, finalBalance: finalBalance));
          }

          checkingAccounts.value = accountsI;
          logger.i('Checking accounts loaded from database');
        },
      );
    } catch (e) {
      logger.e('❌ Error loading checking accounts: $e');
    }
  }

  double get totalEnabledAccountsBalance {
    return checkingAccounts
        .where((account) => account.isEnabled.value)
        .fold(0, (sum, account) => sum + account.finalBalance);
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
    super.onClose();
  }
}
