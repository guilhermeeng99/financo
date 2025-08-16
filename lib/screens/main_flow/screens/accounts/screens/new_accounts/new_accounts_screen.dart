import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/new_accounts/new_accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/new_accounts/new_accounts_model.dart';

class NewAccountsPopUp extends HookWidget {
  const NewAccountsPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bloc = newAccountsBloc;

      return CWPopUp(
        title: context.t.new_account,
        centerContent: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            spacing: 20,
            children: [
              TextField(
                onChanged: (value) => bloc.name.value = value,
                cursorColor: Theme.of(context).textTheme.titleMedium?.color,
                cursorHeight: 22,
                style: const TextStyle(fontSize: 18, color: Color(0xff5887B8)),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: context.t.name,
                  hintStyle: TextStyle(
                    color: Theme.of(context).customColors.textColor,
                  ),
                ),
              ),

              DropdownButtonFormField<AccountType>(
                initialValue: bloc.selectedAccountType.value,

                onChanged: (AccountType? value) {
                  if (value != null) {
                    bloc.selectedAccountType.value = value;
                  }
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tipo de Conta',
                ),
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                style: const TextStyle(fontSize: 18, color: Color(0xff5887B8)),
                items: AccountType.values.map((AccountType type) {
                  return DropdownMenuItem<AccountType>(
                    value: type,
                    child: Text(
                      accountsController.accountTypeName(
                        type: type,
                        context: context,
                      ),
                    ),
                  );
                }).toList(),
              ),

              TextField(
                onChanged: (value) {
                  final balance =
                      double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                  bloc.initialBalance.value = balance;
                },
                keyboardType: TextInputType.number,
                cursorColor: Theme.of(context).textTheme.titleMedium?.color,
                cursorHeight: 22,
                style: const TextStyle(fontSize: 18, color: Color(0xff5887B8)),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: r'(R$)',
                  hintStyle: TextStyle(
                    color: Theme.of(context).customColors.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomContent: Align(
          alignment: const Alignment(0.9, 0),
          child: CWSquareButton(onTap: () => newAccountsModel.onTapSave()),
        ),
      );
    });
  }
}
