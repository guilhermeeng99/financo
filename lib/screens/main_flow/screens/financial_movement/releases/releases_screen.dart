import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/widgets/accounts_results_widget.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_widget.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/releases_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/widgets/releases_screen_accounts_list.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/releases/widgets/releases_screen_transaction_area.dart';

class ReleasesScreen extends StatelessWidget {
  const ReleasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const CWTransactionsTableFloatingActionButton(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Obx(() {
            final transactions = releasesBloc.filteredTransactions;

            return Row(
              spacing: 20,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    spacing: 10,
                    children: [
                      const CWCalendarNavigator(),
                      CWCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
                          ),
                          child: Column(
                            spacing: 25,
                            children: [
                              const CWAReleasesScreenAccountsList(),
                              CWAccountsResults(transactions: transactions),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CWAReleasesScreenTransactions(transactions: transactions),
              ],
            );
          }),
        ),
      ),
    );
  }
}
