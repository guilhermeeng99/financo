import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

AccountsBloc get accountsBloc => Modular.get<AccountsBloc>();

class AccountsBloc extends GetxController {
  AccountsBloc() {
    loadGroupedAccounts();
  }

  final RxMap<AccountType, List<AccountData>> groupedAccounts =
      <AccountType, List<AccountData>>{}.obs;

  Future<void> loadGroupedAccounts() async {
    try {
      final cacheManager = DataCacheManager();

      final grouped = <AccountType, List<AccountData>>{};

      for (final type in AccountType.values) {
        final accounts = cacheManager.accounts.getByType(type);
        if (accounts.isNotEmpty) {
          grouped[type] = accounts;
        }
      }

      groupedAccounts.value = grouped;
      logger.i('✅ Grouped accounts loaded from cache');
    } catch (e) {
      logger.e('❌ Error loading accounts from cache: $e');
    }
  }

  @override
  void onClose() {
    groupedAccounts.close();
    super.onClose();
  }
}

AccountsController get accountsController => Modular.get<AccountsController>();

class AccountsController {
  String accountBankIcon(AccountIconType type) {
    switch (type) {
      case AccountIconType.none:
        return images.banks.bank.path;
      case AccountIconType.nubank:
        return images.banks.nubank.path;
    }
  }

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

  String currencyName({
    required CurrencyType currency,
    required BuildContext context,
  }) {
    switch (currency) {
      case CurrencyType.brl:
        return context.t.currency_type.brl;
      case CurrencyType.usd:
        return context.t.currency_type.usd;
      case CurrencyType.eur:
        return context.t.currency_type.eur;
    }
  }

  String currencyImage(CurrencyType currency) {
    switch (currency) {
      case CurrencyType.brl:
        return images.flags.brazil.path;
      case CurrencyType.usd:
        return images.flags.unitedStates.path;
      case CurrencyType.eur:
        return images.flags.unitedKingdom.path;
    }
  }
}
