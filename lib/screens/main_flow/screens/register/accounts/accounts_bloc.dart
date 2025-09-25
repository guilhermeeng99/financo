import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

AccountsBloc get accountsBloc => Modular.get<AccountsBloc>();

class AccountsBloc extends GetxController {
  AccountsBloc() {
    unawaited(loadGroupedAccounts());

    ever(showOnlyActiveAccounts, (_) => unawaited(loadGroupedAccounts()));
  }
  IAccountUsecase get _accountUsecase => Modular.get<IAccountUsecase>();

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
          CWSnackBar.snackBar(title: failure.message, type: SnackBarType.error);
        },
        (grouped) {
          groupedAccounts.value = grouped;
          logger.i('✅ Grouped accounts loaded from database');
        },
      );
    } on Exception catch (e) {
      logger.e('❌ Error loading accounts: $e');
    }
  }

  @override
  void onClose() {
    groupedAccounts.close();
    super.onClose();
  }
}
