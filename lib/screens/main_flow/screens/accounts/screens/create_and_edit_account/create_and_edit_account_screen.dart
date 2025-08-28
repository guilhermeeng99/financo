import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/create_and_edit_account/create_and_edit_account_bloc.dart';
import 'package:financo/screens/main_flow/screens/accounts/screens/create_and_edit_account/create_and_edit_account_model.dart';

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
          ? context.t.edit_account
          : context.t.new_account,
      centerContent: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          spacing: 30,
          children: [
            const Row(children: [_Name()]),
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
                CWCalendarDropDown(
                  title: context.t.initial_balance_date,
                  selectedDateRx: createAndEditAccountBloc.selectedInitDate,
                ),
                const _Balance(),
              ],
            ),
          ],
        ),
      ),
      bottomContent: Align(
        alignment: const Alignment(0.9, 0),
        child: CWSquareButton(
          onTap: () => createAndEditAccountModel.onTapSave(args.account),
        ),
      ),
    );
  }
}

class _Type extends StatelessWidget {
  const _Type();

  @override
  Widget build(BuildContext context) {
    return CWPopUpItemTitle(
      title: context.t.type,
      child: Obx(() {
        final selectedType = createAndEditAccountBloc.selectedAccountType.value;
        return DropdownButton<AccountType>(
          value: selectedType,
          onChanged: (AccountType? value) {
            if (value != null) {
              createAndEditAccountBloc.selectedAccountType.value = value;
            }
          },
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: const TextStyle(fontSize: 18),
          underline: const CWPopUpUnderLine(),
          items: AccountType.values.map((AccountType type) {
            return DropdownMenuItem<AccountType>(
              value: type,
              child: Text(type.title(context)),
            );
          }).toList(),
        );
      }),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin();

  @override
  Widget build(BuildContext context) {
    return CWPopUpItemTitle(
      title: context.t.coin,
      child: Obx(() {
        final selectedCurrency =
            createAndEditAccountBloc.selectedCurrencyType.value;
        return DropdownButton<CurrencyType>(
          value: selectedCurrency,
          onChanged: (CurrencyType? value) {
            if (value != null) {
              createAndEditAccountBloc.selectedCurrencyType.value = value;
            }
          },
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: const TextStyle(fontSize: 18),
          underline: const CWPopUpUnderLine(),
          items: CurrencyType.values.map((CurrencyType currency) {
            return DropdownMenuItem<CurrencyType>(
              value: currency,
              child: Row(
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
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon();

  @override
  Widget build(BuildContext context) {
    return CWPopUpItemTitle(
      title: context.t.icon,
      child: Obx(() {
        final selectedIcon = createAndEditAccountBloc.selectedIconType.value;
        return DropdownButton<AccountIconType>(
          value: selectedIcon,
          onChanged: (AccountIconType? value) {
            if (value != null) {
              createAndEditAccountBloc.selectedIconType.value = value;
            }
          },
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          underline: const CWPopUpUnderLine(),
          items: AccountIconType.values.map((AccountIconType icon) {
            return DropdownMenuItem<AccountIconType>(
              value: icon,
              child: Image.asset(
                icon.iconPath,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

class _Balance extends HookWidget {
  const _Balance();

  @override
  Widget build(BuildContext context) {
    final balance = createAndEditAccountBloc.initialBalance.value;
    final formattedBalance = CurrencyFormatter.formatAmount(balance, context);

    final controller = useTextEditingController(text: formattedBalance);

    return Expanded(
      child: CWPopUpItemTitle(
        title: context.t.balance,
        spacing: 12,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [CurrencyInputFormatter()],
          onChanged: (value) {
            final parsedValue = CurrencyFormatter.parseAmount(value, context);
            createAndEditAccountBloc.initialBalance.value = parsedValue;
          },
          cursorColor: Theme.of(context).textTheme.titleMedium?.color,
          cursorHeight: 22,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 10),
            hintText: '0',
            hintStyle: TextStyle(
              color: Theme.of(context).customColors.secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _Name extends HookWidget {
  const _Name();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    useEffect(() {
      controller.text = createAndEditAccountBloc.name.value;
      return null;
    }, [createAndEditAccountBloc.name.value]);

    return Expanded(
      child: TextField(
        controller: controller,
        onChanged: (value) => createAndEditAccountBloc.name.value = value,
        cursorColor: Theme.of(context).textTheme.titleMedium?.color,
        cursorHeight: 22,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 10),
          hintText: '${context.t.name}*',
          hintStyle: TextStyle(
            color: Theme.of(context).customColors.secondaryTextColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
