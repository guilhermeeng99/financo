import 'package:app_core/app_core.dart';
import 'package:app_database/app_database.dart';

class AppDatabaseModule extends Module {
  @override
  void exportedBinds(Injector i) {
    // Database
    i.addSingleton<DatabaseManager>(DatabaseManager.new);

    // Repositories
    i.addSingleton<IAccountRepository>(() => AccountRepositoryImpl(i()));
    i.addSingleton<ICategoryRepository>(() => CategoryRepositoryImpl(i()));
    i.addSingleton<ITransactionRepository>(
      () => TransactionRepositoryImpl(i()),
    );

    // Use Cases
    i.addSingleton<IAccountUsecase>(() => AccountUsecaseImpl(i(), i()));
    i.addSingleton<ICategoryUsecase>(() => CategoryUsecaseImpl(i()));
    i.addSingleton<ITransactionUsecase>(() => TransactionUsecaseImpl(i()));
  }
}
