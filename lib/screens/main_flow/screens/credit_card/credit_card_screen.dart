import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';

class CreditCardScreen extends StatelessWidget {
  const CreditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      floatingActionButton: CWTransactionsTableFloatingActionButton(),
      body: Center(),
    );
  }
}
