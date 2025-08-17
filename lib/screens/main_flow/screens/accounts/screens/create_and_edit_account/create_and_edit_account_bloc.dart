import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CreateAndEditAccountBloc get createAndEditAccountBloc =>
    Modular.get<CreateAndEditAccountBloc>();

class CreateAndEditAccountBloc extends GetxController {
  final RxString name = ''.obs;

  final RxDouble initialBalance = 0.0.obs;

  final selectedAccountType = AccountType.checking.obs;

  final selectedCurrency = CurrencyType.brl.obs;

  final selectedIcon = AccountIconType.none.obs;

  final Rx<DateTime> selectedInitDate = DateTime.now().obs;

  void initializeWithAccountData(AccountData account) {
    name.value = account.name;
    initialBalance.value = account.balance;
    selectedAccountType.value = account.accountType;
    selectedCurrency.value = account.currency;
    selectedIcon.value = account.icon;
    selectedInitDate.value = account.initDate;
  }

  void resetForNewAccount() {
    name.value = '';
    initialBalance.value = 0.0;
    selectedAccountType.value = AccountType.checking;
    selectedCurrency.value = CurrencyType.brl;
    selectedIcon.value = AccountIconType.none;
    selectedInitDate.value = DateTime.now();
  }
}
