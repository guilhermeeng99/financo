import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_account_picker_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_category_picker_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

enum _Tab { expense, income, transfer }

_Tab _tabFor(TransactionImportRow row) {
  if (row.isTransfer) return _Tab.transfer;
  if (row.csvType == CsvTransactionType.receita) return _Tab.income;
  return _Tab.expense;
}

/// Page that shows the parsed transactions CSV preview with full UI to edit
/// each row (date, amount, description, account, category) and remove rows
/// before committing the import. Replaces the old confirmation dialog.
class ImportTransactionsPage extends StatefulWidget {
  const ImportTransactionsPage({required this.preview, super.key});

  final TransactionImportPreview preview;

  @override
  State<ImportTransactionsPage> createState() => _ImportTransactionsPageState();
}

class _ImportTransactionsPageState extends State<ImportTransactionsPage> {
  late List<TransactionImportRow> _rows;
  late int _skippedCount;
  _Tab _filter = _Tab.expense;

  @override
  void initState() {
    super.initState();
    _rows = List.of(widget.preview.rows);
    _skippedCount = widget.preview.skippedRows;
    _filter = _firstNonEmptyTab();
  }

  _Tab _firstNonEmptyTab() {
    if (_rows.any((r) => _tabFor(r) == _Tab.expense)) return _Tab.expense;
    if (_rows.any((r) => _tabFor(r) == _Tab.income)) return _Tab.income;
    if (_rows.any((r) => _tabFor(r) == _Tab.transfer)) return _Tab.transfer;
    return _Tab.expense;
  }

  int _countFor(_Tab tab) =>
      _rows.where((r) => _tabFor(r) == tab).length;

  void _removeRow(int index) {
    setState(() => _rows.removeAt(index));
  }

  void _replaceRow(int index, TransactionImportRow updated) {
    setState(() => _rows[index] = updated);
  }

  Future<void> _editRow(int index) async {
    final row = _rows[index];
    final result = await showModalBottomSheet<TransactionImportRow>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditRowSheet(row: row),
    );
    if (result == null) return;
    _replaceRow(index, result);
  }

  void _onSubmit() {
    context.read<TransactionsBloc>().add(
      TransactionsImportRowsConfirmed(
        rows: _rows,
        skippedCount: _skippedCount,
      ),
    );
  }

  void _onBlocState(BuildContext context, TransactionsState state) {
    if (state is TransactionsImported) {
      // The transactions page already listens to `TransactionsImported` and
      // shows its own snackbar + reloads — pop without our own snackbar.
      context.pop(true);
    } else if (state is TransactionsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedFailure(state.failure))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final categories =
        context.watch<CategoriesCubit>().state.categoriesOrEmpty;
    final accounts = context.watch<AccountsCubit>().state.accountsOrEmpty;

    final missingAccounts = _missingAccounts(_rows, accounts);
    final missingCategories = _missingCategories(_rows, categories);
    final canImport =
        _rows.isNotEmpty &&
        missingAccounts.isEmpty &&
        missingCategories.isEmpty;

    return BlocListener<TransactionsBloc, TransactionsState>(
      listener: _onBlocState,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: FinancoLargeAppBar(
          title: t.transactions.importPageTitle,
          subtitle: t.transactions.importPageSubtitle,
          showBack: true,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FinancoPillToggle<_Tab>(
                    selected: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                    options: [
                      FinancoPillToggleOption(
                        value: _Tab.expense,
                        label: t.transactions.importTabExpense(
                          count: _countFor(_Tab.expense),
                        ),
                        icon: FontAwesomeIcons.arrowUp,
                      ),
                      FinancoPillToggleOption(
                        value: _Tab.income,
                        label: t.transactions.importTabIncome(
                          count: _countFor(_Tab.income),
                        ),
                        icon: FontAwesomeIcons.arrowDown,
                      ),
                      FinancoPillToggleOption(
                        value: _Tab.transfer,
                        label: t.transactions.importTabTransfer(
                          count: _countFor(_Tab.transfer),
                        ),
                        icon: FontAwesomeIcons.arrowRightArrowLeft,
                      ),
                    ],
                  ),
                ),
                if (missingAccounts.isNotEmpty || missingCategories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _MissingBanner(
                      missingAccounts: missingAccounts,
                      missingCategories: missingCategories,
                    ),
                  ),
                if (_skippedCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        t.transactions.importSkippedRowsPill(
                          count: _skippedCount,
                        ),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _RowsList(
                    rows: _rows,
                    filter: _filter,
                    accounts: accounts,
                    categories: categories,
                    onTap: _editRow,
                    onRemove: _removeRow,
                  ),
                ),
              ],
            ),
            BlocBuilder<TransactionsBloc, TransactionsState>(
              buildWhen: (previous, current) =>
                  previous is TransactionsImporting ||
                  current is TransactionsImporting,
              builder: (context, state) {
                if (state is! TransactionsImporting) {
                  return const SizedBox.shrink();
                }
                return _ImportProgressOverlay(state: state);
              },
            ),
          ],
        ),
        bottomNavigationBar: BlocBuilder<TransactionsBloc, TransactionsState>(
          builder: (context, state) => FinancoSubmitBar(
            label: _rows.isEmpty
                ? t.transactions.importNothingLeft
                : t.transactions.importSubmit(count: _rows.length),
            isLoading: state is TransactionsLoading ||
                state is TransactionsImporting,
            isEnabled: canImport,
            onSubmit: _onSubmit,
          ),
        ),
      ),
    );
  }

  List<String> _missingAccounts(
    List<TransactionImportRow> rows,
    List<AccountEntity> accounts,
  ) {
    final keys = {for (final a in accounts) a.name.toLowerCase()};
    final missing = <String>{};
    for (final row in rows) {
      if (!keys.contains(row.accountName.toLowerCase())) {
        missing.add(row.accountName);
      }
      if (row.isTransfer && row.destinationAccountName != null) {
        if (!keys.contains(row.destinationAccountName!.toLowerCase())) {
          missing.add(row.destinationAccountName!);
        }
      }
    }
    return missing.toList();
  }

  List<String> _missingCategories(
    List<TransactionImportRow> rows,
    List<CategoryEntity> categories,
  ) {
    final byId = {for (final c in categories) c.id: c};
    final lookup = <String, Map<String?, bool>>{};
    for (final c in categories.where((c) => c.parentId == null)) {
      lookup.putIfAbsent(c.name.toLowerCase(), () => {})[null] = true;
    }
    for (final c in categories.where((c) => c.parentId != null)) {
      final parent = byId[c.parentId];
      if (parent == null) continue;
      lookup
          .putIfAbsent(parent.name.toLowerCase(), () => {})[c.name
              .toLowerCase()] = true;
    }

    final missing = <String>{};
    for (final row in rows) {
      if (row.isTransfer || row.categoryName == null) continue;
      final parentMap = lookup[row.categoryName!.toLowerCase()];
      if (parentMap == null) {
        missing.add(_categoryDisplay(row));
        continue;
      }
      if (row.subcategoryName != null) {
        if (parentMap[row.subcategoryName!.toLowerCase()] != true) {
          missing.add(_categoryDisplay(row));
        }
      } else {
        if (parentMap[null] != true) {
          missing.add(_categoryDisplay(row));
        }
      }
    }
    return missing.toList();
  }

  String _categoryDisplay(TransactionImportRow row) =>
      row.subcategoryName != null
          ? '${row.categoryName}/${row.subcategoryName}'
          : row.categoryName!;
}

/// Modal-style overlay rendered on top of the import preview while the
/// bloc is in the [TransactionsImporting] state. Blocks interaction with
/// the list (an in-flight import shouldn't be edited) and shows a
/// determinate progress bar with a `processed of total` counter so the
/// user knows how long the operation still has to run.
class _ImportProgressOverlay extends StatelessWidget {
  const _ImportProgressOverlay({required this.state});

  final TransactionsImporting state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = (state.progress * 100).clamp(0, 100).toStringAsFixed(0);

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.transactions.importInProgressTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 8,
                    backgroundColor: colors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.transactions.importProgressCounter(
                        processed: state.processed,
                        total: state.total,
                      ),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
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

class _RowsList extends StatelessWidget {
  const _RowsList({
    required this.rows,
    required this.filter,
    required this.accounts,
    required this.categories,
    required this.onTap,
    required this.onRemove,
  });

  final List<TransactionImportRow> rows;
  final _Tab filter;
  final List<AccountEntity> accounts;
  final List<CategoryEntity> categories;
  final void Function(int globalIndex) onTap;
  final void Function(int globalIndex) onRemove;

  @override
  Widget build(BuildContext context) {
    final indexed = <_Indexed>[];
    for (var i = 0; i < rows.length; i++) {
      if (_tabFor(rows[i]) == filter) {
        indexed.add(_Indexed(row: rows[i], globalIndex: i));
      }
    }
    indexed.sort((a, b) => b.row.date.compareTo(a.row.date));

    if (indexed.isEmpty) return _EmptyTab();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: indexed.length,
      itemBuilder: (_, i) => _RowTile(
        row: indexed[i].row,
        onTap: () => onTap(indexed[i].globalIndex),
        onRemove: () => onRemove(indexed[i].globalIndex),
      ),
    );
  }
}

class _Indexed {
  const _Indexed({required this.row, required this.globalIndex});

  final TransactionImportRow row;
  final int globalIndex;
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.row,
    required this.onTap,
    required this.onRemove,
  });

  final TransactionImportRow row;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dateLabel = formatDayMonth(row.date);

    final isExpenseLike =
        row.csvType == CsvTransactionType.despesa || row.isTransfer;
    final amountColor = isExpenseLike ? colors.expense : colors.income;
    final amountSign = isExpenseLike ? '-' : '+';

    final secondaryLabel = row.isTransfer
        ? '${row.accountName} → ${row.destinationAccountName ?? '?'}'
        : (row.categoryName == null
              ? row.accountName
              : '${_categoryShort(row)} · ${row.accountName}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        dateLabel,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.description.isEmpty
                              ? t.transactions.descriptionHint
                              : row.description,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: row.description.isEmpty
                                ? colors.onBackgroundLight
                                : colors.onBackground,
                            fontWeight: FontWeight.w600,
                            fontStyle: row.description.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secondaryLabel,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onBackgroundLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$amountSign${formatCurrency(row.amount)}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RemoveButton(onPressed: onRemove),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _categoryShort(TransactionImportRow row) =>
      row.subcategoryName != null
          ? '${row.categoryName} › ${row.subcategoryName}'
          : row.categoryName!;
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.error.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.trash,
              size: 13,
              color: colors.error,
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingBanner extends StatelessWidget {
  const _MissingBanner({
    required this.missingAccounts,
    required this.missingCategories,
  });

  final List<String> missingAccounts;
  final List<String> missingCategories;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 14,
                color: colors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.transactions.importMissingAfterEditPrefix,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (missingAccounts.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${t.transactions.importMissingAccounts} '
              '${missingAccounts.join(", ")}',
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.error,
              ),
            ),
          ],
          if (missingCategories.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${t.transactions.importMissingCategories} '
              '${missingCategories.join(", ")}',
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          t.transactions.importEmptyTab,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}

/// Per-row edit sheet. Type is locked here for the same reason it's locked
/// in the live transaction form: switching transfer ↔ non-transfer would
/// invalidate the destination/category fields. The user can delete a row
/// and re-import if the type is wrong.
class _EditRowSheet extends StatefulWidget {
  const _EditRowSheet({required this.row});

  final TransactionImportRow row;

  @override
  State<_EditRowSheet> createState() => _EditRowSheetState();
}

class _EditRowSheetState extends State<_EditRowSheet> {
  late TransactionImportRow _draft;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _draft = widget.row;
    _amountController = TextEditingController(
      text: _draft.amount > 0 ? _draft.amount.toStringAsFixed(2) : '',
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
  void _changeType(_Tab tab) {
    final wasTransfer = _draft.isTransfer;
    final willBeTransfer = tab == _Tab.transfer;

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
          csvType: tab == _Tab.income
              ? CsvTransactionType.receita
              : CsvTransactionType.despesa,
          clearDestinationAccountName: true,
          clearCategoryName: true,
          clearSubcategoryName: true,
        );
      } else if (!willBeTransfer && !wasTransfer) {
        final newCsvType = tab == _Tab.income
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
                (a) =>
                    a.name.toLowerCase() == _draft.accountName.toLowerCase(),
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
    final categories =
        context.read<CategoriesCubit>().state.categoriesOrEmpty;
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
              parent.name.toLowerCase() ==
                  _draft.categoryName!.toLowerCase() &&
              c.name.toLowerCase() ==
                  _draft.subcategoryName!.toLowerCase()) {
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
      missing.add(_draft.isTransfer
          ? t.transactions.sourceAccount
          : t.transactions.account);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.transactions.importMissingFields(fields: missing.join(', ')),
          ),
        ),
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
                      FinancoPillToggle<_Tab>(
                        selected: _tabFor(_draft),
                        onChanged: _changeType,
                        options: [
                          FinancoPillToggleOption(
                            value: _Tab.expense,
                            label: t.transactions.expense,
                            icon: FontAwesomeIcons.arrowUp,
                          ),
                          FinancoPillToggleOption(
                            value: _Tab.income,
                            label: t.transactions.income,
                            icon: FontAwesomeIcons.arrowDown,
                          ),
                          FinancoPillToggleOption(
                            value: _Tab.transfer,
                            label: t.transactions.transfer,
                            icon: FontAwesomeIcons.arrowRightArrowLeft,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FinancoFormSection(
                    label: t.bills.formDetails,
                    children: [
                      FinancoTextField(
                        controller: _amountController,
                        label: t.transactions.amountLabel,
                        hintText: t.transactions.amountHint,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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
                      _PickerRow(
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
                      _PickerRow(
                        icon: FontAwesomeIcons.buildingColumns,
                        label: _draft.isTransfer
                            ? t.transactions.sourceAccount
                            : t.transactions.account,
                        value: _draft.accountName,
                        onTap: () => _pickAccount(destination: false),
                      ),
                      if (_draft.isTransfer) ...[
                        const SizedBox(height: 12),
                        _PickerRow(
                          icon: FontAwesomeIcons.arrowRightArrowLeft,
                          label: t.transactions.destinationAccount,
                          value:
                              _draft.destinationAccountName ??
                              t.transactions.destinationAccount,
                          isPlaceholder:
                              _draft.destinationAccountName == null,
                          onTap: () => _pickAccount(destination: true),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        _PickerRow(
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

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final FaIconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              FaIcon(icon, size: 14, color: colors.onBackgroundLight),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isPlaceholder
                            ? colors.onBackgroundLight
                            : colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 11,
                color: colors.onBackgroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
