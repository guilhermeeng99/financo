import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';

class AppDatabaseModule extends Module {
  @override
  void exportedBinds(Injector i) {
    // Database
    i.addSingleton<DatabaseManager>(DatabaseManager.new);

    // Repositories
    i.addSingleton<IAccountRepository>(() => AccountRepository(i()));
    i.addSingleton<ICategoryRepository>(() => CategoryRepository(i()));

    // Use Cases
    i.addSingleton<AccountUsecase>(() => AccountUsecase(i()));
    i.addSingleton<CategoryUsecase>(() => CategoryUsecase(i()));
  }
}
