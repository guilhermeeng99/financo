import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/calendar/calendar_widget.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_types.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/widgets/past_and_future_releases_accounts_area.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/widgets/past_and_future_releases_accounts_results_area.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/widgets/past_and_future_releases_financial_type_filter_area.dart';

import 'past_and_future_releases_bloc.dart';

class PastAndFutureReleasesScreen extends StatelessWidget {
  const PastAndFutureReleasesScreen({required this.type, super.key});

  final PastAndFutureReleasesType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const CWTransactionsTableFloatingActionButton(),
      body: Center(
        child: Column(
          spacing: 20,
          children: [
            const CWAPastAndFutureReleasesFinancialTypeFilter(),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Row(
                  spacing: 20,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Column(
                        spacing: 10,
                        children: [
                          const CWCalendarNavigator(),
                          CWAPastAndFutureReleasesAccountsResults(type: type),
                          CWAPastAndFutureReleasesAccount(type: type),
                        ],
                      ),
                    ),
                    Obx(() {
                      final customTransactions = pastAndFutureReleasesBloc
                          .getFilteredTransactions(type);
                      return CWTransactionsTable(
                        transactions: customTransactions,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
