import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';

class TransactionsAccount {
  TransactionsAccount({
    required this.account,
    required this.finalBalance,
    required this.finalProjectedBalance,
    bool isEnabled = true,
  }) : isEnabled = isEnabled.obs,
       filteredBalance = finalBalance.obs,
       filteredProjectedBalance = finalProjectedBalance.obs;

  final AccountData account;
  final double finalBalance;
  final double finalProjectedBalance;
  final RxBool isEnabled;
  final RxDouble filteredBalance;
  final RxDouble filteredProjectedBalance;

  void updateFilteredBalances({
    required double newFilteredBalance,
    required double newFilteredProjectedBalance,
  }) {
    filteredBalance.value = newFilteredBalance;
    filteredProjectedBalance.value = newFilteredProjectedBalance;
  }

  void dispose() {
    isEnabled.close();
    filteredBalance.close();
    filteredProjectedBalance.close();
  }
}
