import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_model.dart';

enum AccountMenuAction implements PopupMenuAction<AccountData> {
  edit('edit'),
  freeze('freeze'),
  unfreeze('unfreeze'),
  delete('delete');

  const AccountMenuAction(this.value);

  final String value;

  @override
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

  @override
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

  @override
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

  @override
  bool isVisible(AccountData account) {
    switch (this) {
      case AccountMenuAction.freeze:
        return account.isActive;
      case AccountMenuAction.unfreeze:
        return !account.isActive;
      case AccountMenuAction.edit:
      case AccountMenuAction.delete:
        return true;
    }
  }
}

class CWThreeBallsButton extends StatelessWidget {
  const CWThreeBallsButton(this.account, {super.key});

  final AccountData account;

  @override
  Widget build(BuildContext context) {
    return CWPopupMenuButton<AccountData, AccountMenuAction>(
      item: account,
      actions: AccountMenuAction.values,
    );
  }
}
