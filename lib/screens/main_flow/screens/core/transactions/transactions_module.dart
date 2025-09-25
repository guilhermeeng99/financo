import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_model.dart';

class CoreTransactionsModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<TransactionsModel>(TransactionsModel.new)
      ..addSingleton<TransactionsModelExcel>(TransactionsModelExcel.new)
      ..addSingleton<CoreTransactionsBloc>(CoreTransactionsBloc.new);
  }
}
