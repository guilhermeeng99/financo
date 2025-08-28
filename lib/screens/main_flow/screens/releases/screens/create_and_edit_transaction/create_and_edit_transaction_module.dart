import 'package:app_core/app_core.dart';

import 'create_and_edit_transaction_bloc.dart';
import 'create_and_edit_transaction_model.dart';

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
