import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

CreateAndEditAccountBloc get createAndEditAccountBloc =>
    Modular.get<CreateAndEditAccountBloc>();

class CreateAndEditAccountBloc extends GetxController {
  final RxString name = ''.obs;
  final RxString nameError = ''.obs;

  final RxDouble initialBalance = 0.0.obs;
  final RxString balanceError = ''.obs;

  final selectedAccountType = AccountType.checking.obs;

  final selectedCurrencyType = CurrencyType.brl.obs;

  final selectedIconType = AccountIconType.none.obs;

  final Rx<DateTime> selectedInitDate = DateTime.now().obs;

  void initializeWithAccountData(AccountData account) {
    name.value = account.name;
    initialBalance.value = account.initialBalance;
    selectedAccountType.value = account.accountType;
    selectedCurrencyType.value = account.currencyType;
    selectedIconType.value = account.iconType;
    selectedInitDate.value = account.initDate;
  }

  @override
  void onClose() {
    name.close();
    nameError.close();
    initialBalance.close();
    balanceError.close();
    selectedAccountType.close();
    selectedCurrencyType.close();
    selectedIconType.close();
    selectedInitDate.close();
    super.onClose();
  }
}
