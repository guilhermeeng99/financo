import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_bloc.dart';
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
        child: Obx(() {
          final groupedAccounts = accountsController.groupAccountsByType();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 35,
              children: [
                ...groupedAccounts.entries.map(
                  (entry) => _AccountsTypeArea(
                    accountType: entry.key,
                    accountList: entry.value,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AccountsTypeArea extends StatelessWidget {
  const _AccountsTypeArea({
    required this.accountType,
    required this.accountList,
  });

  final AccountType accountType;
  final List<AccountData> accountList;

  @override
  Widget build(BuildContext context) {
    final title = accountsController.accountTypeName(
      type: accountType,
      context: context,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        ...accountList.map(_AccountItem.new),
      ],
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem(this.account);

  final AccountData account;

  @override
  Widget build(BuildContext context) {
    return CWCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(account.name, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
