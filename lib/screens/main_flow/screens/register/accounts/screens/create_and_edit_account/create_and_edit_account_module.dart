import 'package:app_core/app_core.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/screens/create_and_edit_account/create_and_edit_account_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/screens/create_and_edit_account/create_and_edit_account_model.dart';

class CreateAndEditAccountModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<CreateAndEditAccountModel>(CreateAndEditAccountModel.new)
      ..addSingleton<CreateAndEditAccountBloc>(CreateAndEditAccountBloc.new);
  }
}
