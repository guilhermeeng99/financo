import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/screens/create_and_edit_account/create_and_edit_account_bloc.dart';
import 'package:financo/screens/main_flow/screens/register/accounts/screens/create_and_edit_account/create_and_edit_account_model.dart';

enum CreateAndEditAccountPopUpType { create, edit }

class CreateAndEditAccountPopUpArgs {
  CreateAndEditAccountPopUpArgs({required this.type, this.account});

  final AccountData? account;
  final CreateAndEditAccountPopUpType type;
}

class CreateAndEditAccountPopUp extends HookWidget {
  const CreateAndEditAccountPopUp(this.args, {super.key});

  final CreateAndEditAccountPopUpArgs args;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (args.type == CreateAndEditAccountPopUpType.edit) {
        createAndEditAccountBloc.initializeWithAccountData(args.account!);
      }
      return null;
    }, [args.type, args.account]);

    return CWPopUp(
      title: args.type == CreateAndEditAccountPopUpType.edit
          ? context.t.accounts.edit_account
          : context.t.accounts.new_account,
      centerContent: SizedBox(
        width: 400,
        child: Column(
          spacing: 20,
          children: [
            const _Name(),
            const Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_Type(), _Coin(), _Icon()],
            ),
            Row(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(
                  () => CWCalendarDropDown(
                    title: context.t.common.labels.initial_balance_date,
                    selectedDateRx:
                        createAndEditAccountBloc.selectedInitDate.obs,
                  ),
                ),
                const Expanded(child: _Balance()),
              ],
            ),
          ],
        ),
      ),
      bottomContent: Align(
        alignment: const Alignment(0.9, 0),
        child: CWSquareButton(
          onTap: () =>
              createAndEditAccountModel.onTapSave(args.account, context),
        ),
      ),
    );
  }
}

class _Type extends StatelessWidget {
  const _Type();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedType = createAndEditAccountBloc.selectedAccountType;
      return CWDropdownField<AccountType>(
        title: context.t.common.labels.type,
        value: selectedType,
        items: AccountType.values,
        onChanged: (AccountType? value) {
          if (value != null) {
            createAndEditAccountBloc.updateAccountType(value);
          }
        },
        itemBuilder: (AccountType type, BuildContext context) {
          return Text(type.title(context));
        },
      );
    });
  }
}

class _Coin extends StatelessWidget {
  const _Coin();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedCurrency = createAndEditAccountBloc.selectedCurrencyType;
      return CWDropdownField<CurrencyType>(
        title: context.t.common.labels.coin,
        value: selectedCurrency,
        items: CurrencyType.values,
        onChanged: (CurrencyType? value) {
          if (value != null) {
            createAndEditAccountBloc.updateCurrencyType(value);
          }
        },
        itemBuilder: (CurrencyType currency, BuildContext context) {
          return Row(
            spacing: 7,
            children: [
              Image.asset(
                currency.iconPath,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
              Text(currency.title(context)),
            ],
          );
        },
      );
    });
  }
}

class _Icon extends StatelessWidget {
  const _Icon();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIcon = createAndEditAccountBloc.selectedIconType;
      return CWDropdownField<AccountIconType>(
        title: context.t.common.labels.icon,
        value: selectedIcon,
        items: AccountIconType.values,
        onChanged: (AccountIconType? value) {
          if (value != null) {
            createAndEditAccountBloc.updateIconType(value);
          }
        },
        itemBuilder: (AccountIconType icon, BuildContext context) {
          return Image.asset(
            icon.iconPath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          );
        },
      );
    });
  }
}

class _Name extends HookWidget {
  const _Name();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = createAndEditAccountBloc.name;
      final nameError = createAndEditAccountBloc.formErrors.value.name;

      return CWTextField(
        hintText: '${context.t.common.labels.name}*',
        initialValue: name,
        onChanged: (value) => createAndEditAccountBloc.updateName(value),
        error: nameError,
      );
    });
  }
}

class _Balance extends HookWidget {
  const _Balance();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final balance = createAndEditAccountBloc.initialBalance;
      final balanceError =
          createAndEditAccountBloc.formErrors.value.initialBalance;
      final formattedBalance = CurrencyFormatter.formatAmount(balance, context);

      return CWTextField(
        title: context.t.common.labels.balance,
        hintText: '0',
        initialValue: formattedBalance,
        inputFormatters: [CurrencyInputFormatter()],
        keyboardType: TextInputType.number,
        onChanged: (value) {
          createAndEditAccountBloc.updateInitialBalance(value, context);
        },
        error: balanceError,
      );
    });
  }
}
