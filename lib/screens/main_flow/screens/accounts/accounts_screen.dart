import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_model.dart';
import 'package:financo/screens/main_flow/screens/accounts/widgets/accounts_item_menu_actions.dart.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CWFloatingActionButton(
        tooltipMessage: context.t.new_account,
        onTap: accountsModel.onTapFloatingActionButton,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 60, right: 60),
        child: Obx(() {
          final groupedAccounts = accountsBloc.groupedAccounts;

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
    final title = accountType.title(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [...accountList.map(_AccountItem.new)],
        ),
      ],
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem(this.account);

  final AccountData account;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: account.isActive ? 1 : 0.5,
      child: CWCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Row(
                  children: [
                    Image.asset(account.iconPath, width: 24, height: 24),
                    const Gap(5),
                    Text(account.name),
                    const Spacer(),
                    CWThreeBallsButton(account),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      account.initDate.formattedDateddMMyyyy(context: context),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).customColors.secondaryTextColor,
                      ),
                    ),
                    Image.asset(
                      account.currency.iconPath,
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
