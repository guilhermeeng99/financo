import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/releases/screens/create_and_edit_transaction/create_and_edit_transaction_bloc.dart';
import 'package:financo/screens/main_flow/screens/releases/screens/create_and_edit_transaction/create_and_edit_transaction_model.dart';

enum CreateAndEditTransactionPopUpType { create, edit }

class CreateAndEditTransactionPopUpArgs {
  CreateAndEditTransactionPopUpArgs({required this.type, this.transaction});

  final TransactionData? transaction;
  final CreateAndEditTransactionPopUpType type;
}

class CreateAndEditTransactionPopUp extends HookWidget {
  const CreateAndEditTransactionPopUp(this.args, {super.key});

  final CreateAndEditTransactionPopUpArgs args;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (args.type == CreateAndEditTransactionPopUpType.edit) {
        createAndEditTransactionBloc.initializeWithTransactionData(
          args.transaction!,
        );
      }
      return null;
    }, [args.type, args.transaction]);

    return CWPopUp(
      title: args.type == CreateAndEditTransactionPopUpType.edit
          ? context.t.edit_transaction
          : context.t.new_transaction,
      centerContent: Container(
        width: 500,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          spacing: 30,
          children: [
            if (args.type != CreateAndEditTransactionPopUpType.edit)
              const _Type(),
            Row(
              spacing: 5,
              children: [
                const _Amout(),
                CWCalendarDropDown(
                  title: context.t.date,
                  selectedDateRx: createAndEditTransactionBloc.actualDate,
                ),
                const _Recurrence(),
                const _RecurrenceFrequency(),
              ],
            ),
            const Row(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_Description(), _Account()],
            ),
            const _Category(),
          ],
        ),
      ),
      bottomContent: Align(
        alignment: const Alignment(0.9, 0),
        child: CWSquareButton(
          onTap: () =>
              createAndEditTransactionModel.onTapSave(args.transaction),
        ),
      ),
    );
  }
}

class _Account extends StatelessWidget {
  const _Account();

  @override
  Widget build(BuildContext context) {
    return CWPopUpItemTitle(
      title: context.t.account,
      child: Obx(() {
        final accounts = createAndEditTransactionBloc.accounts;
        final selectedAccountId =
            createAndEditTransactionBloc.selectedAccountId.value;

        return DropdownButton<int?>(
          value: selectedAccountId,
          onChanged: (int? value) {
            createAndEditTransactionBloc.selectedAccountId.value = value;
          },
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: const TextStyle(fontSize: 18),
          underline: const CWPopUpUnderLine(),
          items: [
            DropdownMenuItem<int?>(
              child: Text(
                context.t.select_account,
                style: TextStyle(
                  color: Theme.of(context).customColors.secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            ...accounts.map((AccountData account) {
              return DropdownMenuItem<int?>(
                value: account.id,
                child: Text(account.name),
              );
            }),
          ],
        );
      }),
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
        final selectedType =
            createAndEditTransactionBloc.selectedTransactionType.value;
        return SizedBox(
          width: double.infinity,
          child: DropdownButton<FinancialType>(
            value: selectedType,
            onChanged: (FinancialType? value) {
              if (value != null) {
                createAndEditTransactionBloc.selectedTransactionType.value =
                    value;
              }
            },
            isExpanded: true,
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            style: const TextStyle(fontSize: 18),
            underline: const CWPopUpUnderLine(),
            items: FinancialType.values.map((FinancialType type) {
              return DropdownMenuItem<FinancialType>(
                value: type,
                child: Text(type.title(context)),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}

class _Amout extends HookWidget {
  const _Amout();

  @override
  Widget build(BuildContext context) {
    final amout = createAndEditTransactionBloc.amount.value;
    final formattedAmout = CurrencyFormatter.formatAmount(amout, context);

    final controller = useTextEditingController(text: formattedAmout);

    return Expanded(
      child: CWPopUpItemTitle(
        title: context.t.amout,
        spacing: 12,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [CurrencyInputFormatter()],
          onChanged: (value) {
            final parsedValue = CurrencyFormatter.parseAmount(value, context);
            createAndEditTransactionBloc.amount.value = parsedValue;
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

class _Recurrence extends StatelessWidget {
  const _Recurrence();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedRecurrenceType =
          createAndEditTransactionBloc.selectedRecurrenceType.value;

      return CWPopUpItemTitle(
        title: context.t.recurrence,
        child: DropdownButton<TransactionRecurrenceType>(
          value: selectedRecurrenceType,
          onChanged: (TransactionRecurrenceType? value) {
            if (value != null) {
              createAndEditTransactionBloc.selectedRecurrenceType.value = value;
            }
          },
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: const TextStyle(fontSize: 18),
          underline: const CWPopUpUnderLine(),
          items: TransactionRecurrenceType.values.map((
            TransactionRecurrenceType type,
          ) {
            return DropdownMenuItem<TransactionRecurrenceType>(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _RecurrenceFrequency extends StatelessWidget {
  const _RecurrenceFrequency();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedRecurrenceType =
          createAndEditTransactionBloc.selectedRecurrenceType.value;
      final selectedRecurrenceFrequency =
          createAndEditTransactionBloc.selectedRecurrenceFrequency.value;
      if (selectedRecurrenceType == TransactionRecurrenceType.fixed) {
        return CWPopUpItemTitle(
          title: context.t.frequency,
          child: DropdownButton<TransactionRecurrenceFrequency>(
            value: selectedRecurrenceFrequency,
            onChanged: (TransactionRecurrenceFrequency? value) {
              if (value != null) {
                createAndEditTransactionBloc.selectedRecurrenceFrequency.value =
                    value;
              }
            },
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            style: const TextStyle(fontSize: 18),
            underline: const CWPopUpUnderLine(),
            items: TransactionRecurrenceFrequency.values.map((
              TransactionRecurrenceFrequency frequency,
            ) {
              return DropdownMenuItem<TransactionRecurrenceFrequency>(
                value: frequency,
                child: Text(frequency.displayName),
              );
            }).toList(),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}

class _Description extends HookWidget {
  const _Description();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    useEffect(() {
      controller.text = createAndEditTransactionBloc.description.value;
      return null;
    }, [createAndEditTransactionBloc.description.value]);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: TextField(
          controller: controller,
          onChanged: (value) =>
              createAndEditTransactionBloc.description.value = value,
          cursorColor: Theme.of(context).textTheme.titleMedium?.color,
          cursorHeight: 22,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 10),
            hintText: context.t.description,
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

class _Category extends StatelessWidget {
  const _Category();

  @override
  Widget build(BuildContext context) {
    return CWPopUpItemTitle(
      title: context.t.categories,
      child: Obx(() {
        final categories = createAndEditTransactionBloc.categories;
        final selectedCategoryId =
            createAndEditTransactionBloc.selectedCategoryId.value;

        return DropdownButton<int?>(
          value: selectedCategoryId,
          onChanged: (int? value) {
            createAndEditTransactionBloc.selectedCategoryId.value = value;
          },
          isExpanded: true,
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: const TextStyle(fontSize: 18),
          underline: const CWPopUpUnderLine(),
          items: [
            DropdownMenuItem<int?>(
              child: Text(
                context.t.select_category,
                style: TextStyle(
                  color: Theme.of(context).customColors.secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            ...categories.map((CategoryData category) {
              var displayName = category.name;

              if (category.parentCategoryId != null) {
                final parentCategory = categories.firstWhereOrNull(
                  (cat) => cat.id == category.parentCategoryId,
                );
                if (parentCategory != null) {
                  displayName = '  ${parentCategory.name} / ${category.name}';
                }
              }

              return DropdownMenuItem<int?>(
                value: category.id,
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: category.parentCategoryId == null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
