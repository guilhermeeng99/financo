import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_widget.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';
import 'package:financo/screens/main_flow/screens/credit_card/credit_card_bloc.dart';
import 'package:financo/screens/main_flow/screens/credit_card/widgets/credit_card_results_area.dart';

class CreditCardScreen extends StatelessWidget {
  const CreditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const CWTransactionsTableFloatingActionButton(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Obx(() {
            final transactions = creditCardBloc.filteredTransactions;

            return Row(
              spacing: 20,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: const Column(
                    spacing: 10,
                    children: [
                      CWCalendarNavigator(),
                      _CreditCardDropdown(),
                      CWACreditCardResults(),
                    ],
                  ),
                ),
                CWTransactionsTable(transactions: transactions),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CreditCardDropdown extends StatelessWidget {
  const _CreditCardDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dropdownItems = creditCardBloc.dropdownItems;

      if (!creditCardBloc.hasValidSelection && dropdownItems.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          creditCardBloc.ensureSingleAccountSelected();
        });
      }

      final selectedAccountId = creditCardBloc.selectedAccountId;

      return CWCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CWDropdownField<int>(
            value: selectedAccountId,
            items: dropdownItems,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                creditCardBloc.selectAccount(value);
              }
            },
            itemBuilder: (accountId, context) {
              final account = creditCardBloc.getAccountById(accountId);
              return Text(account.account.name);
            },
          ),
        ),
      );
    });
  }
}
