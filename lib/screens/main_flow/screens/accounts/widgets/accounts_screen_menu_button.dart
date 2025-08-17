import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_model.dart';

enum AccountMenuAction {
  edit('edit'),
  freeze('freeze'),
  unfreeze('unfreeze'),
  delete('delete');

  const AccountMenuAction(this.value);

  final String value;

  String getLabel(BuildContext context) {
    switch (this) {
      case AccountMenuAction.edit:
        return context.t.edit;
      case AccountMenuAction.freeze:
        return context.t.freeze;
      case AccountMenuAction.unfreeze:
        return context.t.unfreeze;
      case AccountMenuAction.delete:
        return context.t.delete;
    }
  }

  IconData getIcon() {
    switch (this) {
      case AccountMenuAction.edit:
        return Icons.edit;
      case AccountMenuAction.freeze:
        return Icons.lock_outline;
      case AccountMenuAction.unfreeze:
        return Icons.lock_open_outlined;
      case AccountMenuAction.delete:
        return Icons.delete;
    }
  }

  void execute(AccountData account) {
    switch (this) {
      case AccountMenuAction.edit:
        accountsModel.onTapUpdateAccountPopUp(account);
      case AccountMenuAction.freeze:
        accountsModel.onTapFreezeOrUnfreeze(account: account, freeze: true);
      case AccountMenuAction.unfreeze:
        accountsModel.onTapFreezeOrUnfreeze(account: account, freeze: false);
      case AccountMenuAction.delete:
        accountsModel.onTapDeleteAccout(account);
    }
  }
}

class AccountsScreenThreeBallsButton extends StatelessWidget {
  const AccountsScreenThreeBallsButton(this.account, {super.key});

  final AccountData account;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).dividerColor;

    return PopupMenuButton<AccountMenuAction>(
      color: Theme.of(context).customColors.third,
      onSelected: (AccountMenuAction action) {
        action.execute(account);
      },
      itemBuilder: (BuildContext context) => AccountMenuAction.values
          .where((action) {
            if (action == AccountMenuAction.freeze) {
              return account.isActive;
            }
            if (action == AccountMenuAction.unfreeze) {
              return !account.isActive;
            }
            return true;
          })
          .map(
            (action) => PopupMenuItem<AccountMenuAction>(
              value: action,
              child: Row(
                spacing: 8,
                children: [
                  Icon(action.getIcon(), color: color, size: 16),
                  Text(
                    action.getLabel(context),
                    style: TextStyle(color: color, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            _ballCircle(context),
            _ballCircle(context),
            _ballCircle(context),
          ],
        ),
      ),
    );
  }

  Container _ballCircle(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
