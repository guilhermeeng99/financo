import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

AccountsBloc get accountsBloc => Modular.get<AccountsBloc>();

class AccountsBloc extends GetxController {
  AccountsBloc() {
    loadAccounts();
  }

  final DatabaseService _databaseService = DatabaseService();
  final RxList<AccountData> _accounts = <AccountData>[].obs;
  List<AccountData> get accounts => _accounts;

  Future<void> loadAccounts() async {
    final result = await _databaseService.accountUsecase.getAllAccounts();

    result.fold(
      (failure) {
        logger.e('Error loading accounts: ${failure.message}');
      },
      (accounts) {
        _accounts.value = accounts;
      },
    );
  }

  @override
  void onClose() {
    _accounts.close();
    super.onClose();
  }
}

AccountsController get accountsController => Modular.get<AccountsController>();

class AccountsController {
  String accountTypeName({
    required AccountType type,
    required BuildContext context,
  }) {
    switch (type) {
      case AccountType.checking:
        return context.t.account_type.checking_account;
      case AccountType.creditCard:
        return context.t.account_type.credit_card;
      case AccountType.others:
        return context.t.account_type.others;
      case AccountType.cash:
        return context.t.account_type.money;
    }
  }

  Map<AccountType, List<AccountData>> groupAccountsByType() {
    final grouped = <AccountType, List<AccountData>>{};

    for (final type in AccountType.values) {
      grouped[type] = [];
    }

    for (final account in accountsBloc.accounts) {
      grouped[account.accountType]?.add(account);
    }

    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }
}
