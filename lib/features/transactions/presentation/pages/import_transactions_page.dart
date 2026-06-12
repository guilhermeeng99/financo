import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/import_preview_scaffold.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/transactions/domain/usecases/import_transactions_csv_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_import_edit_sheet.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_import_missing_banner.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_import_rows_list.dart';
import 'package:financo/features/transactions/presentation/widgets/transaction_import_tab.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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
  TransactionImportTab _filter = TransactionImportTab.expense;

  @override
  void initState() {
    super.initState();
    _rows = List.of(widget.preview.rows);
    _skippedCount = widget.preview.skippedRows;
    _filter = _firstNonEmptyTab();
  }

  TransactionImportTab _firstNonEmptyTab() {
    for (final tab in TransactionImportTab.values) {
      if (_rows.any((r) => transactionImportTabFor(r) == tab)) return tab;
    }
    return TransactionImportTab.expense;
  }

  int _countFor(TransactionImportTab tab) =>
      _rows.where((r) => transactionImportTabFor(r) == tab).length;

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
      builder: (_) => TransactionImportEditSheet(row: row),
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
      context.showSnack(localizedFailure(state.failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoriesCubit>().state.categoriesOrEmpty;
    final accounts = context.watch<AccountsCubit>().state.accountsOrEmpty;
    final missingAccounts = _missingAccounts(_rows, accounts);
    final missingCategories = _missingCategories(_rows, categories);

    return ImportPreviewScaffold<TransactionsBloc, TransactionsState>(
      title: t.transactions.importPageTitle,
      subtitle: t.transactions.importPageSubtitle,
      onStateChanged: _onBlocState,
      typeToggle: _buildTypeToggle(),
      notices: _buildNotices(context, missingAccounts, missingCategories),
      list: TransactionImportRowsList(
        rows: _rows,
        filter: _filter,
        onTap: _editRow,
        onRemove: _removeRow,
      ),
      progressOverlayOf: _progressOverlayOf,
      submitLabel: _rows.isEmpty
          ? t.transactions.importNothingLeft
          : t.transactions.importSubmit(count: _rows.length),
      isSubmitting: (state) =>
          state is TransactionsLoading || state is TransactionsImporting,
      canSubmit:
          _rows.isNotEmpty &&
          missingAccounts.isEmpty &&
          missingCategories.isEmpty,
      onSubmit: _onSubmit,
    );
  }

  Widget _buildTypeToggle() {
    return FinancoPillToggle<TransactionImportTab>(
      selected: _filter,
      onChanged: (f) => setState(() => _filter = f),
      options: [
        FinancoPillToggleOption(
          value: TransactionImportTab.expense,
          label: t.transactions.importTabExpense(
            count: _countFor(TransactionImportTab.expense),
          ),
          icon: FontAwesomeIcons.arrowUp,
        ),
        FinancoPillToggleOption(
          value: TransactionImportTab.income,
          label: t.transactions.importTabIncome(
            count: _countFor(TransactionImportTab.income),
          ),
          icon: FontAwesomeIcons.arrowDown,
        ),
        FinancoPillToggleOption(
          value: TransactionImportTab.transfer,
          label: t.transactions.importTabTransfer(
            count: _countFor(TransactionImportTab.transfer),
          ),
          icon: FontAwesomeIcons.arrowRightArrowLeft,
        ),
      ],
    );
  }

  List<Widget> _buildNotices(
    BuildContext context,
    List<String> missingAccounts,
    List<String> missingCategories,
  ) {
    return [
      if (missingAccounts.isNotEmpty || missingCategories.isNotEmpty)
        TransactionImportMissingBanner(
          missingAccounts: missingAccounts,
          missingCategories: missingCategories,
        ),
      if (_skippedCount > 0)
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            t.transactions.importSkippedRowsPill(count: _skippedCount),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.appColors.onBackgroundLight,
            ),
          ),
        ),
    ];
  }

  /// Modal-style overlay rendered on top of the import preview while the
  /// bloc is in the [TransactionsImporting] state. Blocks interaction with
  /// the list (an in-flight import shouldn't be edited) and shows a
  /// determinate progress bar with a `processed of total` counter so the
  /// user knows how long the operation still has to run.
  ImportProgressOverlay? _progressOverlayOf(TransactionsState state) {
    if (state is! TransactionsImporting) return null;
    return ImportProgressOverlay(
      title: t.transactions.importInProgressTitle,
      counterLabel: t.transactions.importProgressCounter(
        processed: state.processed,
        total: state.total,
      ),
      progress: state.progress,
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
      lookup.putIfAbsent(
        parent.name.toLowerCase(),
        () => {},
      )[c.name.toLowerCase()] = true;
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
