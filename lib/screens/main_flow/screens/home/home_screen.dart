import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_accounts_list.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_calendar.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_categories_by_type.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_results.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      floatingActionButton: CWTransactionsTableFloatingActionButton(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: CWHomeScreenCalendarNavigator(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  spacing: 20,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        CWHomeScreenAccountsList(),
                        CWHomeScreenAccountsResults(),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        CWHomeScreenCategoriesByType(
                          financialType: FinancialType.expense,
                        ),
                        CWHomeScreenCategoriesByType(
                          financialType: FinancialType.income,
                        ),
                      ],
                    ),
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
