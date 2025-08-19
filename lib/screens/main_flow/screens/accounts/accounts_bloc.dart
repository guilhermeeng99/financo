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
      final accountsCache = DataCacheManager().accounts;

      final grouped = <AccountType, List<AccountData>>{};

      for (final type in AccountType.values) {
        final accounts = accountsCache.getByType(type);
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
