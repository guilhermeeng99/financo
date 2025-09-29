import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/create_and_edit_transaction_bloc.dart';
import 'package:financo/screens/main_flow/screens/create_and_edit_transaction/create_and_edit_transaction_model.dart';

class CreateAndEditTransactionModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<CreateAndEditTransactionModel>(
        CreateAndEditTransactionModel.new,
      )
      ..addSingleton<CreateAndEditTransactionBloc>(
        CreateAndEditTransactionBloc.new,
      );
  }
}
