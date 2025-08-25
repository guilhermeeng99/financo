import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

AccountsBloc get accountsBloc => Modular.get<AccountsBloc>();

class AccountsBloc extends GetxController {
  AccountsBloc() {
    loadGroupedAccounts();

    // Observa mudanças no showOnlyActiveAccounts e recarrega as contas
    ever(showOnlyActiveAccounts, (_) => loadGroupedAccounts());
  }
  AccountUsecase get _accountUsecase => Modular.get<AccountUsecase>();

  final RxMap<AccountType, List<AccountData>> groupedAccounts =
      <AccountType, List<AccountData>>{}.obs;

  final RxBool showOnlyActiveAccounts = true.obs;

  Future<void> loadGroupedAccounts() async {
    try {
      final result = await _accountUsecase.getGroupedAccounts(
        onlyActive: showOnlyActiveAccounts.value,
      );

      result.fold(
        (failure) {
          logger.e('❌ Error loading accounts: ${failure.message}');
          AppWidgetsUtils.snackBar(
            title: failure.message,
            type: SnackBarType.error,
          );
        },
        (grouped) {
          groupedAccounts.value = grouped;
          logger.i('✅ Grouped accounts loaded from database');
        },
      );
    } catch (e) {
      logger.e('❌ Error loading accounts: $e');
    }
  }

  @override
  void onClose() {
    groupedAccounts.close();
    super.onClose();
  }
}
