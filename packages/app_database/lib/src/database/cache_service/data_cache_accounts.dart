import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';

class AccountsCacheManager extends BaseCacheManager<AccountData> {
  factory AccountsCacheManager() {
    _instance ??= AccountsCacheManager._();
    return _instance!;
  }
  AccountsCacheManager._();

  static AccountsCacheManager? _instance;

  Map<AccountType, List<AccountData>>? _accountsByType;

  @override
  Future<List<AccountData>?> fetchDataFromSource() async {
    final accountUsecase = Modular.get<AccountUsecase>();
    logger.i('📊 Loading accounts...');

    final accountsResult = await accountUsecase.getAllAccounts();
    return accountsResult.fold((failure) {
      logger.e('❌ Error loading accounts: ${failure.message}');
      throw Exception('Failed to load accounts: ${failure.message}');
    }, (accounts) => accounts);
  }

  @override
  int getItemId(AccountData item) => item.id;

  @override
  String getItemTypeName() => 'accounts';

  @override
  void onDataLoaded(List<AccountData> items) {
    _accountsByType = _groupAccountsByType(items);
  }

  @override
  void onClearCache() {
    _accountsByType = null;
  }

  @override
  Map<String, dynamic> getCustomStatistics() {
    return {
      'accountsByType':
          _accountsByType?.map(
            (key, value) => MapEntry(key.toString(), value.length),
          ) ??
          {},
    };
  }

  List<AccountData> getByType(AccountType type) {
    if (!isLoaded) {
      throw StateError('Data not loaded. Please execute loadData() first.');
    }
    return _accountsByType?[type] ?? [];
  }

  void add(AccountData account) {
    if (allItems != null) {
      allItems!.add(account);
      _accountsByType = _groupAccountsByType(allItems!);
      logger.i('➕ Account added to cache: ${account.name}');
    }
  }

  void update(AccountData updatedAccount) {
    if (allItems != null) {
      final index = allItems!.indexWhere((acc) => acc.id == updatedAccount.id);
      if (index != -1) {
        allItems![index] = updatedAccount;
        _accountsByType = _groupAccountsByType(allItems!);
        logger.i('🔄 Account updated in cache: ${updatedAccount.name}');
      }
    }
  }

  void remove(int accountId) {
    if (allItems != null) {
      allItems!.removeWhere((acc) => acc.id == accountId);
      _accountsByType = _groupAccountsByType(allItems!);
      logger.i('🗑️ Account removed from cache: ID $accountId');
    }
  }

  Map<AccountType, List<AccountData>> _groupAccountsByType(
    List<AccountData> accounts,
  ) {
    final grouped = <AccountType, List<AccountData>>{};

    for (final type in AccountType.values) {
      grouped[type] = accounts
          .where((account) => account.accountType == type)
          .toList();
    }

    return grouped;
  }
}
