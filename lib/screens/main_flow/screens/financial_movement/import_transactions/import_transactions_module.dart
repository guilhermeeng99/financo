import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/import_transactions/import_transactions_model.dart';

class ImportTransactionsModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<ImportTransactionsModel>(ImportTransactionsModel.new);
  }
}
