import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

class TransactionDataLoader {
  TransactionDataLoader({
    required IAccountUsecase accountUsecase,
    required ICategoryUsecase categoryUsecase,
  }) : _accountUsecase = accountUsecase,
       _categoryUsecase = categoryUsecase;

  final IAccountUsecase _accountUsecase;
  final ICategoryUsecase _categoryUsecase;

  Future<Map<String, int>> getAccountsMap() async {
    final accountsResult = await _accountUsecase.getAllAccounts();
    return accountsResult.fold(
      (Failure failure) {
        logger.e('Error loading accounts: ${failure.message}');
        return <String, int>{};
      },
      (List<AccountData> accounts) {
        final accountsMap = <String, int>{};
        for (final account in accounts) {
          accountsMap[account.name] = account.id;
        }
        logger.i('Loaded ${accountsMap.length} accounts');
        return accountsMap;
      },
    );
  }

  Future<Map<String, int>> getCategoriesMap() async {
    final incomeResult = await _categoryUsecase.getCategoriesByType(
      FinancialType.income,
    );
    final expenseResult = await _categoryUsecase.getCategoriesByType(
      FinancialType.expense,
    );

    final categoriesMap = <String, int>{};

    incomeResult.fold(
      (Failure failure) =>
          logger.e('Error loading income categories: ${failure.message}'),
      (List<CategoryData> categories) {
        for (final category in categories) {
          categoriesMap[category.name] = category.id;
        }
      },
    );

    expenseResult.fold(
      (Failure failure) =>
          logger.e('Error loading expense categories: ${failure.message}'),
      (List<CategoryData> categories) {
        for (final category in categories) {
          categoriesMap[category.name] = category.id;
        }
      },
    );

    logger.i('Loaded ${categoriesMap.length} categories');
    return categoriesMap;
  }
}
