import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

ReleasesBloc get releasesBloc => Modular.get<ReleasesBloc>();

class ReleasesBloc extends GetxController {
  ReleasesBloc() {
    loadTransactions();
  }
  final RxList<TransactionData> transactions = <TransactionData>[].obs;

  TransactionUsecase get _transactionUsecase =>
      Modular.get<TransactionUsecase>();

  Future<void> loadTransactions() async {
    try {
      final result = await _transactionUsecase.getAllTransactions();

      result.fold(
        (failure) {
          logger.e('Error loading transactions: ${failure.message}');
          AppWidgetsUtils.snackBar(
            title: failure.message,
            type: SnackBarType.error,
          );
        },
        (transactionsList) {
          transactions.value = transactionsList;
          logger.i('Transactions loaded from database');
        },
      );
    } catch (e) {
      logger.e('❌ Error loading transactions: $e');
    }
  }

  @override
  void onClose() {
    transactions.close();
    super.onClose();
  }
}
