import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/import_transactions/import_transactions_model.dart';

class ImportTransactionsModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<ImportTransactionsModel>(ImportTransactionsModel.new);
  }
}
