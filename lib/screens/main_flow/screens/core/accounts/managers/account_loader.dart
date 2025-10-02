import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/transaction_account_data.dart';

class AccountLoader {
  static Future<List<TransactionsAccount>> loadCheckingAccounts() async {
    final accountUsecase = Modular.get<IAccountUsecase>();

    try {
      final result = await accountUsecase.getCheckingAccounts();

      return await result.fold((failure) {
        _handleLoadAccountsError(failure);
        return <TransactionsAccount>[];
      }, _processLoadedAccounts);
    } on Exception catch (e) {
      logger.e('❌ Unexpected error loading checking accounts: $e');
      _showErrorMessage('Failed to load accounts');
      return <TransactionsAccount>[];
    }
  }

  static Future<List<TransactionsAccount>> loadCreditCardAccounts() async {
    final accountUsecase = Modular.get<IAccountUsecase>();

    try {
      final result = await accountUsecase.getCreditCardAccounts();

      return await result.fold((failure) {
        logger.e('Error loading credit card accounts: ${failure.message}');
        CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        return <TransactionsAccount>[];
      }, _processLoadedAccounts);
    } on Exception catch (e) {
      logger.e('❌ Unexpected error loading credit card accounts: $e');
      _showErrorMessage('Failed to load credit card accounts');
      return <TransactionsAccount>[];
    }
  }

  static void _handleLoadAccountsError(Failure failure) {
    logger.e('Error loading checking accounts: ${failure.message}');
    CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
  }

  static Future<List<TransactionsAccount>> _processLoadedAccounts(
    List<AccountData> checkingAccountsList,
  ) async {
    final accountsI = <TransactionsAccount>[];

    for (final account in checkingAccountsList) {
      final transactionsAccount = TransactionsAccount(
        account: account,
        finalBalance: 0,
        finalProjectedBalance: 0,
      );

      accountsI.add(transactionsAccount);
    }

    return accountsI;
  }

  static void _showErrorMessage(String message) {
    CWSnackBar.snackBar(title: message, type: SnackBarType.error);
  }
}
