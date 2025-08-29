import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

ReleasesBloc get releasesBloc => Modular.get<ReleasesBloc>();

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

class ReleasesBloc extends GetxController {
  ReleasesBloc() {
    loadTransactions();
  }
  final RxList<TransactionI> transactions = <TransactionI>[].obs;

  TransactionUsecase get _transactionUsecase =>
      Modular.get<TransactionUsecase>();

  Future<void> loadTransactions() async {
    try {
      final result = await _transactionUsecase.getAllTransactions();

      await result.fold(
        (failure) {
          logger.e('Error loading transactions: ${failure.message}');
          AppWidgetsUtils.snackBar(
            title: failure.message,
            type: SnackBarType.error,
          );
        },
        (transactionsList) async {
          final transactionsWithAccountNames = <TransactionI>[];

          for (final transaction in transactionsList) {
            final accountName = await _getAccountName(transaction.accountId);
            final categoryName = await _getCategoryName(transaction.categoryId);
            transactionsWithAccountNames.add(
              TransactionI(
                t: transaction,
                accountName: accountName,
                categoryName: categoryName,
              ),
            );
          }

          transactions.value = transactionsWithAccountNames;
          logger.i('Transactions with account names loaded from database');
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

  @override
  void onClose() {
    transactions.close();
    super.onClose();
  }
}
