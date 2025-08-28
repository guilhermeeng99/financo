import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CreateAndEditAccountBloc get createAndEditAccountBloc =>
    Modular.get<CreateAndEditAccountBloc>();

class CreateAndEditAccountBloc extends GetxController {
  final RxString name = ''.obs;

  final RxDouble initialBalance = 0.0.obs;

  final selectedAccountType = AccountType.checking.obs;

  final selectedCurrencyType = CurrencyType.brl.obs;

  final selectedIconType = AccountIconType.none.obs;

  final Rx<DateTime> selectedInitDate = DateTime.now().obs;

  void initializeWithAccountData(AccountData account) {
    name.value = account.name;
    initialBalance.value = account.balance;
    selectedAccountType.value = account.accountType;
    selectedCurrencyType.value = account.currencyType;
    selectedIconType.value = account.iconType;
    selectedInitDate.value = account.initDate;
  }

  @override
  void onClose() {
    name.close();
    initialBalance.close();
    selectedAccountType.close();
    selectedCurrencyType.close();
    selectedIconType.close();
    selectedInitDate.close();
    super.onClose();
  }
}
