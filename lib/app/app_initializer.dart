import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class AppIntializer {
  static Future<void> initializeBeforeApp() async {
    await _configureLocalization();
  }

  static Future<void> initializeOnLoading() async {
    try {
      final databaseManager = Modular.get<DatabaseManager>();

      await databaseManager.customSelect('SELECT 1').get();

      await _showAllCategories();
      await _showAllAccounts();
    } catch (e) {
      logger.e('❌ Error during database initialization: $e');
    }
  }

  static Future<void> _configureLocalization() async {
    await LocaleSettings.setPluralResolver(
      language: 'pt',
      cardinalResolver:
          (
            num n, {
            String? zero,
            String? one,
            String? two,
            String? few,
            String? many,
            String? other,
          }) {
            if (n == 1) {
              return one ?? other ?? '';
            }
            return other ?? one ?? '';
          },
    );
    await LocaleSettings.useDeviceLocale();
  }
}

Future<void> _showAllCategories() async {
  final categoryUsecase = Modular.get<ICategoryUsecase>();
  final categoriesResult = await categoryUsecase.getCategoriesMapAsync();

  categoriesResult.fold(
    (Failure failure) =>
        logger.e('❌ Error loading categories: ${failure.message}'),
    (Map<FinancialType, Map<CategoryData, List<CategoryData>>> categoriesMap) {
      final buffer = StringBuffer()
        ..writeln('📁 Categories and subcategories loaded:');

      var totalCategories = 0;
      for (final entry in categoriesMap.entries) {
        buffer.writeln('  📂 ${entry.key.name.toUpperCase()} categories:');

        for (final categoryEntry in entry.value.entries) {
          final parentCategory = categoryEntry.key;
          final subcategories = categoryEntry.value;

          totalCategories++;
          buffer.writeln(
            '    📁 ${parentCategory.name} (ID: ${parentCategory.id})',
          );

          for (final subcategory in subcategories) {
            totalCategories++;
            buffer.writeln(
              '      📄 ${subcategory.name} (ID: ${subcategory.id})',
            );
          }
        }
      }

      buffer.writeln('📊 Total categories loaded: $totalCategories');
      logger.i(buffer.toString().trim());
    },
  );
}

Future<void> _showAllAccounts() async {
  final accountUsecase = Modular.get<IAccountUsecase>();
  final accountsResult = await accountUsecase.getGroupedAccounts();

  accountsResult.fold(
    (failure) => logger.e('❌ Error loading accounts: ${failure.message}'),
    (groupedAccounts) {
      final buffer = StringBuffer()..writeln('💳 Grouped accounts loaded:');

      var totalAccounts = 0;
      for (final entry in groupedAccounts.entries) {
        final accountType = entry.key;
        final accounts = entry.value;

        buffer.writeln('  💼 ${accountType.name.toUpperCase()} accounts:');

        for (final account in accounts) {
          totalAccounts++;
          buffer.writeln(
            '    💳 ${account.name} (Balance: ${account.initialBalance}, ID: ${account.id})',
          );
        }
      }

      buffer.writeln('📊 Total accounts loaded: $totalAccounts');
      logger.i(buffer.toString().trim());
    },
  );
}
