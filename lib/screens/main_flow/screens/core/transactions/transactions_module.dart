import 'package:app_core/app_core.dart';

import 'transactions_bloc.dart';
import 'transactions_model.dart';

class CoreTransactionsModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<TransactionsModel>(TransactionsModel.new)
      ..addSingleton<TransactionsModelExcel>(TransactionsModelExcel.new)
      ..addSingleton<CoreTransactionsBloc>(CoreTransactionsBloc.new);
  }
}
