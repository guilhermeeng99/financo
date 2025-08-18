import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/accounts/accounts_bloc.dart';
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
      } else {
        createAndEditAccountBloc.resetForNewAccount();
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
        child: const Column(
          spacing: 30,
          children: [
            Row(children: [_Name()]),
            Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_Type(), _Coin(), _Icon()],
            ),
            Row(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_InitDate(), _Balance()],
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
    return _ItemTitle(
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
          underline: _dropdownUnderline(context),

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
        );
      }),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin();

  @override
  Widget build(BuildContext context) {
    return _ItemTitle(
      title: context.t.coin,
      child: Obx(() {
        final selectedCurrency =
            createAndEditAccountBloc.selectedCurrency.value;
        return DropdownButton<CurrencyType>(
          value: selectedCurrency,
          onChanged: (CurrencyType? value) {
            if (value != null) {
              createAndEditAccountBloc.selectedCurrency.value = value;
            }
          },
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: const TextStyle(fontSize: 18),
          underline: _dropdownUnderline(context),
          items: CurrencyType.values.map((CurrencyType currency) {
            return DropdownMenuItem<CurrencyType>(
              value: currency,
              child: Row(
                spacing: 7,
                children: [
                  Image.asset(
                    accountsController.currencyImage(currency),
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    accountsController.currencyName(
                      currency: currency,
                      context: context,
                    ),
                  ),
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
    return _ItemTitle(
      title: context.t.icon,
      child: Obx(() {
        final selectedIcon = createAndEditAccountBloc.selectedIcon.value;
        return DropdownButton<AccountIconType>(
          value: selectedIcon,
          onChanged: (AccountIconType? value) {
            if (value != null) {
              createAndEditAccountBloc.selectedIcon.value = value;
            }
          },
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          underline: _dropdownUnderline(context),
          items: AccountIconType.values.map((AccountIconType icon) {
            return DropdownMenuItem<AccountIconType>(
              value: icon,
              child: Image.asset(
                accountsController.accountBankIcon(icon),
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
    final formattedBalance = CurrencyHelper.formatAmount(balance, context);

    final controller = useTextEditingController(text: formattedBalance);

    return Expanded(
      child: _ItemTitle(
        title: context.t.balance,
        spacing: 12,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [CurrencyInputFormatter()],
          onChanged: (value) {
            final parsedValue = CurrencyHelper.parseAmount(value, context);
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

class _ItemTitle extends StatelessWidget {
  const _ItemTitle({
    required this.child,
    required this.title,
    this.spacing = 0,
  });

  final Widget child;
  final String title;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).customColors.secondaryTextColor,
          ),
        ),
        child,
      ],
    );
  }
}

class _InitDate extends StatelessWidget {
  const _InitDate();

  @override
  Widget build(BuildContext context) {
    return _ItemTitle(
      title: context.t.initial_balance_date,
      spacing: 10,
      child: Obx(() {
        final selectedDate = createAndEditAccountBloc.selectedInitDate.value;
        return GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 25,
              children: [
                Text(
                  selectedDate.formattedDateddMMyyyy(context: context),
                  style: const TextStyle(fontSize: 16),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).customColors.secondaryTextColor,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: _buildCalendarConfig(context),
      dialogSize: const Size(320, 400),
      borderRadius: BorderRadius.circular(16),
      value: [createAndEditAccountBloc.selectedInitDate.value],
      dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );

    if (results != null && results.isNotEmpty && results.first != null) {
      createAndEditAccountBloc.selectedInitDate.value = results.first!;
    }
  }

  CalendarDatePicker2WithActionButtonsConfig _buildCalendarConfig(
    BuildContext context,
  ) {
    const baseTextStyle = TextStyle(fontSize: 16);

    final secondaryTextStyle = baseTextStyle.copyWith(
      color: Theme.of(context).customColors.secondaryTextColor,
    );

    final selectedTextStyle = baseTextStyle.copyWith(
      color: Theme.of(context).textTheme.bodyMedium?.color,
      fontWeight: FontWeight.w500,
    );

    return CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.single,
      selectedDayHighlightColor: Theme.of(context).customColors.button01,
      firstDayOfWeek: 0,
      controlsHeight: 56,
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
      dayBorderRadius: BorderRadius.circular(8),
      selectedRangeHighlightColor: Theme.of(context).customColors.button01,
      selectableDayPredicate: (day) =>
          !day.isAfter(DateTime.now().add(const Duration(days: 365))),

      selectedDayTextStyle: baseTextStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      todayTextStyle: baseTextStyle.copyWith(
        color: Theme.of(context).customColors.button01,
        fontWeight: FontWeight.w600,
      ),
      weekdayLabelTextStyle: secondaryTextStyle.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      dayTextStyle: selectedTextStyle,
      disabledDayTextStyle: secondaryTextStyle,
      controlsTextStyle: baseTextStyle.copyWith(
        color: Theme.of(context).textTheme.titleMedium?.color,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      monthTextStyle: secondaryTextStyle,
      selectedMonthTextStyle: selectedTextStyle,
      yearTextStyle: secondaryTextStyle,
      selectedYearTextStyle: selectedTextStyle,
    );
  }
}

Container _dropdownUnderline(BuildContext context) {
  return Container(height: 0.5, color: Theme.of(context).dividerColor);
}
