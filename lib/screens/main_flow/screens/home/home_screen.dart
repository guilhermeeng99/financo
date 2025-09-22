import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_accounts_list.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_calendar.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_results.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      floatingActionButton: CWTransactionsTableFloatingActionButton(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            CWHomeScreenCalendarNavigator(),
            CWHomeScreenAccountsList(),
            CWHomeScreenAccountsResults(),
          ],
        ),
      ),
    );
  }
}
