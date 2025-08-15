import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_model.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CWFloatingActionButton(
        onTap: accountsModel.onTapFloatingActionButton,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 60, right: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 35,
          children: [
            Text(context.t.account_type.checking_account),
            const CWCard(child: Text('olasdasd')),
          ],
        ),
      ),
    );
  }
}
