import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/widgets/accounts_area_widget.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/widgets/accounts_results_widget.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_widget.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_types.dart';

import 'past_and_future_releases_bloc.dart';

class PastAndFutureReleasesScreen extends StatelessWidget {
  const PastAndFutureReleasesScreen({required this.type, super.key});

  final PastAndFutureReleasesScreenType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const CWTransactionsTableFloatingActionButton(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Obx(() {
            final customTransactions = pastAndFutureReleasesBloc
                .getFilteredTransactions(type);
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
                            const  CWAccountsList(),
                              CWAccountsResults(
                                transactions: customTransactions,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CWTransactionsTable(transactions: customTransactions),
              ],
            );
          }),
        ),
      ),
    );
  }
}
