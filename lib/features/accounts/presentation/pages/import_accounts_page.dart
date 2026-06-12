import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/import_preview_scaffold.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/widgets/account_import_edit_sheet.dart';
import 'package:financo/features/accounts/presentation/widgets/account_import_missing_link_banner.dart';
import 'package:financo/features/accounts/presentation/widgets/account_import_rows_list.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Page that shows the parsed accounts CSV preview with full UI to edit
/// each row (name, type, bank, balance, credit-card fields, linked
/// checking account) and remove rows before committing the import.
class ImportAccountsPage extends StatefulWidget {
  const ImportAccountsPage({required this.preview, super.key});

  final AccountImportPreview preview;

  @override
  State<ImportAccountsPage> createState() => _ImportAccountsPageState();
}

class _ImportAccountsPageState extends State<ImportAccountsPage> {
  late List<AccountImportPreviewItem> _items;
  AccountType _filter = AccountType.checking;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.preview.toCreate);
    _filter = _items.any((it) => it.type == AccountType.checking)
        ? AccountType.checking
        : AccountType.creditCard;
  }

  int _countFor(AccountType type) =>
      _items.where((it) => it.type == type).length;

  // Removing a checking account also drops any credit cards that were
  // pointing at it — otherwise they'd silently fail at import (no parent).
  void _removeItem(int globalIndex) {
    final removed = _items[globalIndex];
    setState(() {
      _items.removeAt(globalIndex);
      if (removed.type == AccountType.checking) {
        for (var i = 0; i < _items.length; i++) {
          final it = _items[i];
          if (it.isCreditCard &&
              (it.linkedAccountName?.toLowerCase() ==
                  removed.name.toLowerCase())) {
            _items[i] = it.copyWith(clearLinkedAccountName: true);
          }
        }
      }
    });
  }

  void _replaceItem(int globalIndex, AccountImportPreviewItem updated) {
    final original = _items[globalIndex];
    setState(() {
      _items[globalIndex] = updated;
      // Renaming a checking account propagates to the credit cards that
      // referenced it — keeps the parent lookup valid at import time.
      if (original.type == AccountType.checking &&
          original.name != updated.name) {
        for (var i = 0; i < _items.length; i++) {
          final it = _items[i];
          if (it.isCreditCard &&
              (it.linkedAccountName?.toLowerCase() ==
                  original.name.toLowerCase())) {
            _items[i] = it.copyWith(linkedAccountName: updated.name);
          }
        }
      }
    });
  }

  Future<void> _editItem(int globalIndex) async {
    final item = _items[globalIndex];
    final result = await showModalBottomSheet<AccountImportPreviewItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountImportEditSheet(
        item: item,
        otherCheckingNames: _checkingNamesExcluding(globalIndex),
      ),
    );
    if (result == null) return;
    _replaceItem(globalIndex, result);
  }

  List<String> _checkingNamesExcluding(int globalIndex) {
    final out = <String>[];
    for (var i = 0; i < _items.length; i++) {
      if (i == globalIndex) continue;
      final it = _items[i];
      if (it.type == AccountType.checking) out.add(it.name);
    }
    return out;
  }

  void _onSubmit() {
    unawaited(
      context.read<AccountsCubit>().confirmImport(
        items: _items,
        duplicateCount: widget.preview.duplicates.length,
      ),
    );
  }

  void _onCubitState(BuildContext context, AccountsState state) {
    if (state is AccountsImported) {
      context
        ..showSnack(
          t.accounts.importSuccessDetailed(
            imported: state.importedCount,
            duplicates: state.duplicateCount,
          ),
        )
        ..pop(true);
    } else if (state is AccountsError) {
      context.showSnack(localizedFailure(state.failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final missingLinkedFor = _missingLinkedAccounts(context);

    return ImportPreviewScaffold<AccountsCubit, AccountsState>(
      title: t.accounts.importPageTitle,
      subtitle: t.accounts.importPageSubtitle,
      onStateChanged: _onCubitState,
      typeToggle: _buildTypeToggle(),
      notices: [
        if (missingLinkedFor.isNotEmpty)
          AccountImportMissingLinkBanner(missing: missingLinkedFor),
      ],
      list: AccountImportRowsList(
        items: _items,
        duplicates: widget.preview.duplicates,
        filter: _filter,
        onTap: _editItem,
        onRemove: _removeItem,
      ),
      progressOverlayOf: _progressOverlayOf,
      submitLabel: _items.isEmpty
          ? t.accounts.importNothingLeft
          : t.accounts.importSubmit(count: _items.length),
      isSubmitting: (state) =>
          state is AccountsLoading || state is AccountsImporting,
      canSubmit: _items.isNotEmpty && missingLinkedFor.isEmpty,
      onSubmit: _onSubmit,
    );
  }

  Widget _buildTypeToggle() {
    return FinancoPillToggle<AccountType>(
      selected: _filter,
      onChanged: (f) => setState(() => _filter = f),
      options: [
        FinancoPillToggleOption(
          value: AccountType.checking,
          label: t.accounts.importTabChecking(
            count: _countFor(AccountType.checking),
          ),
          icon: FontAwesomeIcons.buildingColumns,
        ),
        FinancoPillToggleOption(
          value: AccountType.creditCard,
          label: t.accounts.importTabCreditCard(
            count: _countFor(AccountType.creditCard),
          ),
          icon: FontAwesomeIcons.creditCard,
        ),
      ],
    );
  }

  /// Modal-style overlay rendered on top of the import preview while the
  /// cubit is in the [AccountsImporting] state. Blocks interaction with the
  /// list (an in-flight import shouldn't be edited) and shows a determinate
  /// progress bar with a `processed of total` counter so the user knows how
  /// long the operation still has to run.
  ImportProgressOverlay? _progressOverlayOf(AccountsState state) {
    if (state is! AccountsImporting) return null;
    return ImportProgressOverlay(
      title: t.accounts.importInProgressTitle,
      counterLabel: t.accounts.importProgressCounter(
        processed: state.processed,
        total: state.total,
      ),
      progress: state.progress,
    );
  }

  /// Credit cards whose linked checking account is neither an existing
  /// account nor part of this import batch — they would silently fail at
  /// import time, so the page blocks submission and lists them in a banner.
  List<String> _missingLinkedAccounts(BuildContext context) {
    final existingCheckingNames = {
      for (final a in context.watch<AccountsCubit>().state.accountsOrEmpty)
        if (a.type == AccountType.checking) a.name.toLowerCase(),
    };
    final inImportCheckingNames = {
      for (final it in _items)
        if (it.type == AccountType.checking) it.name.toLowerCase(),
    };

    final missing = <String>[];
    for (final it in _items) {
      if (!it.isCreditCard) continue;
      final linkedKey = it.linkedAccountName?.toLowerCase();
      final resolved =
          linkedKey != null &&
          (existingCheckingNames.contains(linkedKey) ||
              inImportCheckingNames.contains(linkedKey));
      if (!resolved) missing.add(it.name);
    }
    return missing;
  }
}
