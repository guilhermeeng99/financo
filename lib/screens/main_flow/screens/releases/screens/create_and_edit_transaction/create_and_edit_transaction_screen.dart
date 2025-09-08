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
          ? context.t.transactions.edit_transaction
          : context.t.transactions.new_transaction,
      centerContent: Container(
        width: 500,
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          spacing: 30,
          children: [
            if (args.type != CreateAndEditTransactionPopUpType.edit)
              const _Type(),
            Row(
              spacing: 5,
              children: [
                const Expanded(child: _Amount()),
                CWCalendarDropDown(
                  title: context.t.common.labels.date,
                  selectedDateRx: createAndEditTransactionBloc.actualDate,
                ),
                const _Recurrence(),
                const _RecurrenceFrequency(),
              ],
            ),
            const Row(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _Description()),
                _Account(),
              ],
            ),
            const _Category(),
          ],
        ),
      ),
      bottomContent: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _PaymentStatusToggle(),
            CWSquareButton(
              onTap: () => createAndEditTransactionModel.onTapSave(
                args.transaction,
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Account extends StatelessWidget {
  const _Account();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final accounts = createAndEditTransactionBloc.accounts;
      final selectedAccountId =
          createAndEditTransactionBloc.selectedAccountId.value;
      final accountError = createAndEditTransactionBloc.accountError.value;

      final items = <AccountData?>[null, ...accounts];

      return CWDropdownField<AccountData?>(
        title: context.t.common.labels.account(n: 1),
        error: accountError,
        value: selectedAccountId != null
            ? accounts.firstWhereOrNull((acc) => acc.id == selectedAccountId)
            : null,
        items: items,
        onChanged: (AccountData? account) {
          createAndEditTransactionBloc.selectedAccountId.value = account?.id;
        },
        itemBuilder: (AccountData? account, BuildContext context) {
          if (account == null) {
            return Text(
              context.t.accounts.select_account,
              style: TextStyle(
                color: Theme.of(context).customColors.secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            );
          }
          return Text(account.name);
        },
      );
    });
  }
}

class _Type extends StatelessWidget {
  const _Type();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedType =
          createAndEditTransactionBloc.selectedTransactionType.value;

      return CWDropdownField<FinancialType>(
        title: context.t.common.labels.type,
        value: selectedType,
        items: FinancialType.values,
        isExpanded: true,
        onChanged: (FinancialType? value) {
          if (value != null) {
            createAndEditTransactionBloc.selectedTransactionType.value = value;
          }
        },
        itemBuilder: (FinancialType type, BuildContext context) {
          return Text(type.title(context));
        },
      );
    });
  }
}

class _Amount extends HookWidget {
  const _Amount();

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final lastKnownAmount = useRef<double?>(null);

    final amount = createAndEditTransactionBloc.amount.value;

    useMemoized(() {
      if (lastKnownAmount.value != amount) {
        final formattedAmount = CurrencyFormatter.formatAmount(amount, context);
        if (controller.text.isEmpty || controller.text != formattedAmount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.text != formattedAmount) {
              controller.text = formattedAmount;
            }
          });
        }
        lastKnownAmount.value = amount;
      }
      return amount;
    }, [amount]);

    return Obx(() {
      final currentAmountError = createAndEditTransactionBloc.amountError.value;

      return CWTextField(
        title: context.t.common.labels.amount,
        hintText: '0',
        controller: controller,
        inputFormatters: [CurrencyInputFormatter()],
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final parsedValue = CurrencyFormatter.parseAmount(value, context);
          createAndEditTransactionBloc.amount.value = parsedValue;
        },
        error: currentAmountError,
      );
    });
  }
}

class _Recurrence extends StatelessWidget {
  const _Recurrence();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedRecurrenceType =
          createAndEditTransactionBloc.selectedRecurrenceType.value;
      return CWDropdownField<TransactionRecurrenceType>(
        title: context.t.common.labels.type,
        value: selectedRecurrenceType,
        items: TransactionRecurrenceType.values,
        onChanged: (TransactionRecurrenceType? value) {
          if (value != null) {
            createAndEditTransactionBloc.selectedRecurrenceType.value = value;
          }
        },
        itemBuilder: (TransactionRecurrenceType type, BuildContext context) {
          return Text(type.displayName(context));
        },
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
        return CWDropdownField<TransactionRecurrenceFrequency>(
          title: context.t.common.labels.frequency,
          value: selectedRecurrenceFrequency,
          items: TransactionRecurrenceFrequency.values,
          onChanged: (TransactionRecurrenceFrequency? value) {
            if (value != null) {
              createAndEditTransactionBloc.selectedRecurrenceFrequency.value =
                  value;
            }
          },
          itemBuilder:
              (TransactionRecurrenceFrequency frequency, BuildContext context) {
                return Text(frequency.displayName(context));
              },
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
    return Obx(() {
      final description = createAndEditTransactionBloc.description.value;
      final descriptionError =
          createAndEditTransactionBloc.descriptionError.value;

      return CWTextField(
        hintText: context.t.common.labels.description,
        initialValue: description,
        onChanged: (value) {
          createAndEditTransactionBloc.description.value = value;
        },
        error: descriptionError,
      );
    });
  }
}

class _Category extends StatelessWidget {
  const _Category();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = createAndEditTransactionBloc.categories;
      final selectedCategoryId =
          createAndEditTransactionBloc.selectedCategoryId.value;
      final categoryError = createAndEditTransactionBloc.categoryError.value;

      final items = <CategoryData?>[null, ...categories];

      return CWDropdownField<CategoryData?>(
        title: context.t.common.labels.category(n: 1),
        value: selectedCategoryId != null
            ? categories.firstWhereOrNull((cat) => cat.id == selectedCategoryId)
            : null,
        items: items,
        error: categoryError,
        isExpanded: true,
        onChanged: (CategoryData? category) {
          createAndEditTransactionBloc.selectedCategoryId.value = category?.id;
        },
        itemBuilder: (CategoryData? category, BuildContext context) {
          if (category == null) {
            return Text(
              context.t.categories.select_category,
              style: TextStyle(
                color: Theme.of(context).customColors.secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            );
          }

          var displayName = category.name;

          if (category.parentCategoryId != null) {
            final parentCategory = categories.firstWhereOrNull(
              (cat) => cat.id == category.parentCategoryId,
            );
            if (parentCategory != null) {
              displayName = '  ${parentCategory.name} / ${category.name}';
            }
          }

          return Text(
            displayName,
            style: TextStyle(
              fontWeight: category.parentCategoryId == null
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
          );
        },
      );
    });
  }
}

class _PaymentStatusToggle extends StatelessWidget {
  const _PaymentStatusToggle();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final paymentStatus =
          createAndEditTransactionBloc.selectedPaymentStatus.value;
      final isPaid = paymentStatus == TransactionPaymentStatus.paid;

      return InkWell(
        onTap: () {
          createAndEditTransactionBloc.selectedPaymentStatus.value = isPaid
              ? TransactionPaymentStatus.unpaid
              : TransactionPaymentStatus.paid;
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: isPaid
                ? Theme.of(context).customColors.button01
                : Theme.of(context).customColors.fourth,
          ),
          child: Icon(
            Icons.done_all,
            size: 24,
            color: isPaid ? Theme.of(context).customColors.fourth : null,
          ),
        ),
      );
    });
  }
}
