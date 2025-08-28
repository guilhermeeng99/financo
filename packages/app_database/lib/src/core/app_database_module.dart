import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';
import 'package:app_database/src/items/account/account_repository.dart';
import 'package:app_database/src/items/category/category_repository.dart';
import 'package:app_database/src/items/transaction/transaction_repository.dart';

class AppDatabaseModule extends Module {
  @override
  void exportedBinds(Injector i) {
    // Database
    i.addSingleton<DatabaseManager>(DatabaseManager.new);

    // Repositories
    i.addSingleton<IAccountRepository>(() => AccountRepository(i()));
    i.addSingleton<ICategoryRepository>(() => CategoryRepository(i()));
    i.addSingleton<ITransactionRepository>(() => TransactionRepository(i()));

    // Use Cases
    i.addSingleton<AccountUsecase>(() => AccountUsecase(i()));
    i.addSingleton<CategoryUsecase>(() => CategoryUsecase(i()));
    i.addSingleton<TransactionUsecase>(() => TransactionUsecase(i()));
  }
}
