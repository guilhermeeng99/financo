import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/widgets/accounts_results_widget.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_widget.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/account_statement/account_statement_bloc.dart';

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const CWTransactionsTableFloatingActionButton(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Obx(() {
            final transactions = accountStatementBloc.filteredTransactions;

            return Row(
              spacing: 20,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    spacing: 10,
                    children: [
                      const CWCalendarNavigator(),
                      const _DropdownAccount(),
                      CWCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
                          ),
                          child: CWAccountsResults(transactions: transactions),
                        ),
                      ),
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

class _DropdownAccount extends StatelessWidget {
  const _DropdownAccount();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dropdownItems = accountStatementBloc.dropdownItems;

      if (!accountStatementBloc.hasValidSelection && dropdownItems.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          accountStatementBloc.ensureSingleAccountSelected();
        });
      }

      final selectedAccountId = accountStatementBloc.selectedAccountId;

      return CWCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CWDropdownField<int>(
            value: selectedAccountId,
            items: dropdownItems,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                accountStatementBloc.selectAccount(value);
              }
            },
            itemBuilder: (accountId, context) {
              final account = accountStatementBloc.getAccountById(accountId);
              return Text(account.account.name);
            },
          ),
        ),
      );
    });
  }
}
