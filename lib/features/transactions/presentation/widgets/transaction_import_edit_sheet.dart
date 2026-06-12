import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_account_picker_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_category_picker_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_import_tab.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Per-row edit sheet of the transactions import preview. Pops with the
/// edited [TransactionImportRow], or `null` when dismissed. Type is locked
/// here for the same reason it's locked in the live transaction form:
/// switching transfer ↔ non-transfer would invalidate the
/// destination/category fields. The user can delete a row and re-import
/// if the type is wrong.
///
/// ```dart
/// final edited = await showModalBottomSheet<TransactionImportRow>(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => TransactionImportEditSheet(row: row),
/// );
/// ```
class TransactionImportEditSheet extends StatefulWidget {
  const TransactionImportEditSheet({required this.row, super.key});

  final TransactionImportRow row;

  @override
  State<TransactionImportEditSheet> createState() =>
      _TransactionImportEditSheetState();
}

class _TransactionImportEditSheetState
    extends State<TransactionImportEditSheet> {
  late TransactionImportRow _draft;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _draft = widget.row;
    // Seed with BR-formatted text so the first paint matches what
    // `BrlCurrencyInputFormatter` produces on edit (mirrors the accounts
    // import sheet). `parseDecimalAmount` reads it back on save.
    _amountController = TextEditingController(
      text: _draft.amount > 0
          ? BrlCurrencyInputFormatter.format(_draft.amount)
          : '',
    );
    _descriptionController = TextEditingController(text: _draft.description);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    // Expand `lastDate` when the draft already has a future date —
    // otherwise `showDatePicker`'s assert (`initialDate ≤ lastDate`)
    // fires and the field becomes uneditable.
    final lastDate = _draft.date.isAfter(now) ? _draft.date : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.date,
      firstDate: DateTime(2020),
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _draft = _draft.copyWith(date: picked));
  }

  // Switching kind clears fields that no longer apply: category for any
  // transition (income/expense use different categories; transfers have
  // none), and destinationAccountName when leaving Transfer. Source account
  // is preserved so the user keeps their account context.
  void _changeType(TransactionImportTab tab) {
    final wasTransfer = _draft.isTransfer;
    final willBeTransfer = tab == TransactionImportTab.transfer;

    setState(() {
      if (willBeTransfer && !wasTransfer) {
        _draft = _draft.copyWith(
          csvType: CsvTransactionType.transferencia,
          clearCategoryName: true,
          clearSubcategoryName: true,
          clearDestinationAccountName: true,
        );
      } else if (!willBeTransfer && wasTransfer) {
        _draft = _draft.copyWith(
          csvType: tab == TransactionImportTab.income
              ? CsvTransactionType.receita
              : CsvTransactionType.despesa,
          clearDestinationAccountName: true,
          clearCategoryName: true,
          clearSubcategoryName: true,
        );
      } else if (!willBeTransfer && !wasTransfer) {
        final newCsvType = tab == TransactionImportTab.income
            ? CsvTransactionType.receita
            : CsvTransactionType.despesa;
        if (newCsvType != _draft.csvType) {
          _draft = _draft.copyWith(
            csvType: newCsvType,
            clearCategoryName: true,
            clearSubcategoryName: true,
          );
        }
      }
    });
  }

  Future<void> _pickAccount({required bool destination}) async {
    final accounts = context.read<AccountsCubit>().state.accountsOrEmpty;

    final selectedName = destination
        ? _draft.destinationAccountName
        : _draft.accountName;
    final selectedId = accounts
        .where((a) => a.name.toLowerCase() == selectedName?.toLowerCase())
        .map((a) => a.id)
        .firstOrNull;
    final excludeId = destination
        ? accounts
              .where(
                (a) => a.name.toLowerCase() == _draft.accountName.toLowerCase(),
              )
              .map((a) => a.id)
              .firstOrNull
        : null;

    final pickedId = await showTransactionAccountPicker(
      context: context,
      title: destination
          ? t.transactions.destinationAccount
          : t.transactions.account,
      selectedId: selectedId,
      excludeId: excludeId,
    );
    if (pickedId == null) return;
    final pickedName = accounts
        .where((a) => a.id == pickedId)
        .map((a) => a.name)
        .firstOrNull;
    if (pickedName == null) return;

    setState(() {
      _draft = destination
          ? _draft.copyWith(destinationAccountName: pickedName)
          : _draft.copyWith(accountName: pickedName);
    });
  }

  Future<void> _pickCategory() async {
    final categories = context.read<CategoriesCubit>().state.categoriesOrEmpty;
    final byId = {for (final c in categories) c.id: c};

    final type = _draft.csvType == CsvTransactionType.receita
        ? TransactionType.income
        : TransactionType.expense;
    final categoryType = type == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;

    String? selectedId;
    if (_draft.categoryName != null) {
      for (final c in categories) {
        if (c.type != categoryType) continue;
        if (_draft.subcategoryName != null) {
          final parent = c.parentId == null ? null : byId[c.parentId];
          if (parent != null &&
              parent.name.toLowerCase() == _draft.categoryName!.toLowerCase() &&
              c.name.toLowerCase() == _draft.subcategoryName!.toLowerCase()) {
            selectedId = c.id;
            break;
          }
        } else {
          if (c.parentId == null &&
              c.name.toLowerCase() == _draft.categoryName!.toLowerCase()) {
            selectedId = c.id;
            break;
          }
        }
      }
    }

    final pickedId = await showTransactionCategoryPicker(
      context: context,
      transactionType: type,
      selectedId: selectedId,
    );
    if (pickedId == null) return;
    final picked = byId[pickedId];
    if (picked == null) return;

    setState(() {
      if (picked.parentId == null) {
        _draft = _draft.copyWith(
          categoryName: picked.name,
          clearSubcategoryName: true,
        );
      } else {
        final parent = byId[picked.parentId];
        _draft = _draft.copyWith(
          categoryName: parent?.name ?? picked.name,
          subcategoryName: picked.name,
        );
      }
    });
  }

  /// Returns the localized labels for fields the user still has to fill
  /// (or fix) before this row can be saved. Used by [_save] to spell out
  /// the reason in a snackbar instead of silently disabling the button.
  List<String> _missingFields() {
    final missing = <String>[];
    // `parseDecimalAmount` handles both BR (`1.234,56`) and EN (`1234.56`)
    // styles — the previous naive `replaceAll(',', '.')` parsed BR values
    // with thousands separators as null.
    final amount = parseDecimalAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      missing.add(t.transactions.amountLabel);
    }
    if (_draft.accountName.isEmpty) {
      missing.add(
        _draft.isTransfer
            ? t.transactions.sourceAccount
            : t.transactions.account,
      );
    }
    if (_draft.isTransfer) {
      final dest = _draft.destinationAccountName;
      if (dest == null || dest.isEmpty) {
        missing.add(t.transactions.destinationAccount);
      } else if (dest.toLowerCase() == _draft.accountName.toLowerCase()) {
        // Same source/destination — surface as "destination account"
        // so the user knows which one to change.
        missing.add(t.transactions.destinationAccount);
      }
    } else if (_draft.categoryName == null || _draft.categoryName!.isEmpty) {
      missing.add(t.transactions.category);
    }
    return missing;
  }

  void _save() {
    final missing = _missingFields();
    if (missing.isNotEmpty) {
      context.showSnack(
        t.transactions.importMissingFields(fields: missing.join(', ')),
      );
      return;
    }
    // Safe to assert non-null: [_missingFields] above already gated this
    // path on `parseDecimalAmount` returning a positive value.
    final amount = parseDecimalAmount(_amountController.text)!;
    Navigator.of(context).pop(
      _draft.copyWith(
        amount: amount,
        description: _descriptionController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final dateLabel = formatDate(_draft.date);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onBackgroundLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.transactions.importEditTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + viewInsets),
                children: [
                  FinancoFormSection(
                    label: t.transactions.type,
                    children: [
                      FinancoPillToggle<TransactionImportTab>(
                        selected: transactionImportTabFor(_draft),
                        onChanged: _changeType,
                        options: [
                          FinancoPillToggleOption(
                            value: TransactionImportTab.expense,
                            label: t.transactions.expense,
                            icon: FontAwesomeIcons.arrowUp,
                          ),
                          FinancoPillToggleOption(
                            value: TransactionImportTab.income,
                            label: t.transactions.income,
                            icon: FontAwesomeIcons.arrowDown,
                          ),
                          FinancoPillToggleOption(
                            value: TransactionImportTab.transfer,
                            label: t.transactions.transfer,
                            icon: FontAwesomeIcons.arrowRightArrowLeft,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FinancoFormSection(
                    label: t.payablesReceivables.formDetails,
                    children: [
                      FinancoCurrencyField(
                        controller: _amountController,
                        label: t.transactions.amountLabel,
                        hintText: t.transactions.amountHint,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      FinancoTextField(
                        controller: _descriptionController,
                        label: t.transactions.description,
                        hintText: t.transactions.descriptionHint,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      ImportPickerRow(
                        icon: FontAwesomeIcons.calendar,
                        label: t.transactions.date,
                        value: dateLabel,
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FinancoFormSection(
                    label: _draft.isTransfer
                        ? t.transactions.transfer
                        : t.transactions.account,
                    children: [
                      ImportPickerRow(
                        icon: FontAwesomeIcons.buildingColumns,
                        label: _draft.isTransfer
                            ? t.transactions.sourceAccount
                            : t.transactions.account,
                        value: _draft.accountName,
                        onTap: () => _pickAccount(destination: false),
                      ),
                      if (_draft.isTransfer) ...[
                        const SizedBox(height: 12),
                        ImportPickerRow(
                          icon: FontAwesomeIcons.arrowRightArrowLeft,
                          label: t.transactions.destinationAccount,
                          value:
                              _draft.destinationAccountName ??
                              t.transactions.destinationAccount,
                          isPlaceholder: _draft.destinationAccountName == null,
                          onTap: () => _pickAccount(destination: true),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        ImportPickerRow(
                          icon: FontAwesomeIcons.tag,
                          label: t.transactions.category,
                          value: _draft.subcategoryName != null
                              ? '${_draft.categoryName} › '
                                    '${_draft.subcategoryName}'
                              : (_draft.categoryName ??
                                    t.transactions.category),
                          isPlaceholder: _draft.categoryName == null,
                          onTap: _pickCategory,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            FinancoSubmitBar(
              label: t.general.save,
              onSubmit: _save,
              // Always tappable: `_save` shows a snackbar with the missing
              // fields when invalid. Disabling silently was misleading
              // users into thinking the form had no problem.
            ),
          ],
        ),
      ),
    );
  }
}
