import 'package:app_core/app_core.dart';

import 'import_transactions_model.dart';

class ImportTransactionsModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<ImportTransactionsModel>(ImportTransactionsModel.new);
  }
}
