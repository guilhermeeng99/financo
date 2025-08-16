import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

NewAccountsBloc get newAccountsBloc => Modular.get<NewAccountsBloc>();

class NewAccountsBloc extends GetxController {
  final RxString name = ''.obs;

  final RxDouble initialBalance = 0.0.obs;

  final selectedAccountType = AccountType.checking.obs;

  bool get canSave => name.value.trim().isNotEmpty;

}
