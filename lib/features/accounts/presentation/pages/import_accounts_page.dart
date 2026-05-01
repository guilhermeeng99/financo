import 'dart:async';

import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/widgets/day_picker_sheet.dart';
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
      builder: (_) => _EditItemSheet(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.accounts.importSuccessDetailed(
              imported: state.importedCount,
              duplicates: state.duplicateCount,
            ),
          ),
        ),
      );
      context.pop(true);
    } else if (state is AccountsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.failure.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final accountsState = context.watch<AccountsCubit>().state;
    final existingCheckingNames = accountsState is AccountsLoaded
        ? {
            for (final a in accountsState.accounts)
              if (a.type == AccountType.checking) a.name.toLowerCase(),
          }
        : <String>{};

    final inImportCheckingNames = {
      for (final it in _items)
        if (it.type == AccountType.checking) it.name.toLowerCase(),
    };

    final missingLinkedFor = <String>[];
    for (final it in _items) {
      if (!it.isCreditCard) continue;
      final linkedKey = it.linkedAccountName?.toLowerCase();
      if (linkedKey == null ||
          (!existingCheckingNames.contains(linkedKey) &&
              !inImportCheckingNames.contains(linkedKey))) {
        missingLinkedFor.add(it.name);
      }
    }

    final canImport = _items.isNotEmpty && missingLinkedFor.isEmpty;

    return BlocListener<AccountsCubit, AccountsState>(
      listener: _onCubitState,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: FinancoLargeAppBar(
          title: t.accounts.importPageTitle,
          subtitle: t.accounts.importPageSubtitle,
          showBack: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FinancoPillToggle<AccountType>(
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
              ),
            ),
            if (missingLinkedFor.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _MissingLinkBanner(missing: missingLinkedFor),
              ),
            Expanded(
              child: _ImportList(
                items: _items,
                duplicates: widget.preview.duplicates,
                filter: _filter,
                onTap: _editItem,
                onRemove: _removeItem,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BlocBuilder<AccountsCubit, AccountsState>(
          builder: (context, state) => FinancoSubmitBar(
            label: _items.isEmpty
                ? t.accounts.importNothingLeft
                : t.accounts.importSubmit(count: _items.length),
            isLoading: state is AccountsLoading,
            isEnabled: canImport,
            onSubmit: _onSubmit,
          ),
        ),
      ),
    );
  }
}

class _ImportList extends StatelessWidget {
  const _ImportList({
    required this.items,
    required this.duplicates,
    required this.filter,
    required this.onTap,
    required this.onRemove,
  });

  final List<AccountImportPreviewItem> items;
  final List<AccountImportPreviewItem> duplicates;
  final AccountType filter;
  final void Function(int globalIndex) onTap;
  final void Function(int globalIndex) onRemove;

  @override
  Widget build(BuildContext context) {
    final indexed = <_Indexed>[];
    for (var i = 0; i < items.length; i++) {
      if (items[i].type == filter) {
        indexed.add(_Indexed(item: items[i], globalIndex: i));
      }
    }
    indexed.sort(
      (a, b) =>
          a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase()),
    );

    final filteredDuplicates = duplicates
        .where((it) => it.type == filter)
        .toList();

    if (indexed.isEmpty && filteredDuplicates.isEmpty) return _EmptyTab();

    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        for (final entry in indexed)
          _ImportRow(
            item: entry.item,
            onTap: () => onTap(entry.globalIndex),
            onRemove: () => onRemove(entry.globalIndex),
          ),
        if (filteredDuplicates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              t.accounts.importDuplicatesHeader.toUpperCase(),
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackgroundLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          for (final dup in filteredDuplicates)
            Opacity(
              opacity: 0.55,
              child: _ImportRow(
                item: dup,
                onTap: null,
                onRemove: null,
              ),
            ),
        ],
      ],
    );
  }
}

class _Indexed {
  const _Indexed({required this.item, required this.globalIndex});

  final AccountImportPreviewItem item;
  final int globalIndex;
}

class _ImportRow extends StatelessWidget {
  const _ImportRow({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final AccountImportPreviewItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final secondary = item.isCreditCard
        ? _creditSubtitle(item)
        : '${t.accounts.balance}: ${formatCurrency(item.initialBalance)}';

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
                  BankAvatar(bank: item.bank),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: colors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secondary,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onBackgroundLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(width: 4),
                    _RemoveButton(onPressed: onRemove!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _creditSubtitle(AccountImportPreviewItem it) {
    final parts = <String>[];
    if (it.creditLimit != null) {
      parts.add(
        '${t.accounts.creditLimit}: ${formatCurrency(it.creditLimit!)}',
      );
    }
    if (it.linkedAccountName != null) {
      parts.add('→ ${it.linkedAccountName}');
    }
    if (parts.isEmpty) return t.accounts.creditCard;
    return parts.join(' · ');
  }
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

class _MissingLinkBanner extends StatelessWidget {
  const _MissingLinkBanner({required this.missing});

  final List<String> missing;

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
                  t.accounts.importMissingLinkPrefix,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            missing.join(', '),
            style: context.textTheme.bodySmall?.copyWith(color: colors.error),
          ),
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
          t.accounts.importEmptyTab,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}

/// Per-row edit sheet. Switching type clears the conditional fields:
/// going checking → credit card requires the user to fill credit-limit,
/// closing/due day, and pick a linked checking account; going credit
/// card → checking drops all of them.
class _EditItemSheet extends StatefulWidget {
  const _EditItemSheet({
    required this.item,
    required this.otherCheckingNames,
  });

  final AccountImportPreviewItem item;

  /// Checking accounts being imported in this batch (excluding the
  /// currently-edited row), used to populate the linked-account picker
  /// alongside any existing checking accounts.
  final List<String> otherCheckingNames;

  @override
  State<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<_EditItemSheet> {
  late AccountImportPreviewItem _draft;
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _draft = widget.item;
    _nameController = TextEditingController(text: _draft.name);
    _balanceController = TextEditingController(
      text: _draft.initialBalance.toStringAsFixed(2),
    );
    _limitController = TextEditingController(
      text: (_draft.creditLimit ?? 0) > 0
          ? _draft.creditLimit!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _changeType(AccountType type) {
    if (type == _draft.type) return;
    setState(() {
      if (type == AccountType.checking) {
        _draft = _draft.copyWith(
          type: AccountType.checking,
          clearCreditLimit: true,
          clearClosingDay: true,
          clearDueDay: true,
          clearLinkedAccountName: true,
        );
        _limitController.text = '';
      } else {
        _draft = _draft.copyWith(type: AccountType.creditCard);
      }
    });
  }

  Future<void> _pickClosingDay() async {
    final picked = await showDayPickerSheet(
      context: context,
      selected: _draft.closingDay,
      title: t.accounts.pickClosingDay,
    );
    if (picked != null) {
      setState(() => _draft = _draft.copyWith(closingDay: picked));
    }
  }

  Future<void> _pickDueDay() async {
    final picked = await showDayPickerSheet(
      context: context,
      selected: _draft.dueDay,
      title: t.accounts.pickDueDay,
    );
    if (picked != null) {
      setState(() => _draft = _draft.copyWith(dueDay: picked));
    }
  }

  Future<void> _pickLinkedAccount() async {
    final accountsState = context.read<AccountsCubit>().state;
    final existing = accountsState is AccountsLoaded
        ? accountsState.accounts
              .where((a) => a.type == AccountType.checking)
              .map((a) => a.name)
              .toList()
        : <String>[];

    final candidates = <String>{...existing, ...widget.otherCheckingNames}
        .toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.accounts.noLinkedCandidates)),
      );
      return;
    }

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LinkedAccountPicker(
        candidates: candidates,
        selectedName: _draft.linkedAccountName,
      ),
    );
    if (picked == null) return;
    setState(() => _draft = _draft.copyWith(linkedAccountName: picked));
  }

  bool get _isValid {
    if (_nameController.text.trim().isEmpty) return false;
    if (_draft.isCreditCard) {
      if ((_draft.creditLimit ?? 0) <= 0) return false;
      if (_draft.closingDay == null || _draft.dueDay == null) return false;
      if (_draft.linkedAccountName == null ||
          _draft.linkedAccountName!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void _save() {
    if (!_isValid) return;
    final balance =
        double.tryParse(_balanceController.text.replaceAll(',', '.')) ?? 0;
    final limit =
        double.tryParse(_limitController.text.replaceAll(',', '.')) ?? 0;
    Navigator.of(context).pop(
      _draft.copyWith(
        name: _nameController.text.trim(),
        initialBalance: balance,
        creditLimit: _draft.isCreditCard ? limit : null,
        clearCreditLimit: !_draft.isCreditCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

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
                  t.accounts.importEditTitle,
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
                    label: t.accounts.formSectionType,
                    children: [
                      FinancoPillToggle<AccountType>(
                        selected: _draft.type,
                        onChanged: _changeType,
                        options: [
                          FinancoPillToggleOption(
                            value: AccountType.checking,
                            label: t.accounts.checking,
                            icon: FontAwesomeIcons.buildingColumns,
                          ),
                          FinancoPillToggleOption(
                            value: AccountType.creditCard,
                            label: t.accounts.creditCard,
                            icon: FontAwesomeIcons.creditCard,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FinancoFormSection(
                    label: t.accounts.formSectionDetails,
                    children: [
                      FinancoTextField(
                        controller: _nameController,
                        label: t.accounts.name,
                        hintText: t.accounts.nameHint,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      FinancoTextField(
                        controller: _balanceController,
                        label: t.accounts.balanceLabel,
                        hintText: t.accounts.balanceHint,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _BankToggle(
                        selected: _draft.bank,
                        onChanged: (b) =>
                            setState(() => _draft = _draft.copyWith(bank: b)),
                      ),
                    ],
                  ),
                  if (_draft.isCreditCard) ...[
                    const SizedBox(height: 20),
                    FinancoFormSection(
                      label: t.accounts.formSectionCreditCard,
                      children: [
                        FinancoTextField(
                          controller: _limitController,
                          label: t.accounts.creditLimitLabel,
                          hintText: t.accounts.creditLimitHint,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _PickerRow(
                                icon: FontAwesomeIcons.calendar,
                                label: t.accounts.closingDay,
                                value: _draft.closingDay?.toString() ??
                                    t.accounts.pickClosingDay,
                                isPlaceholder: _draft.closingDay == null,
                                onTap: _pickClosingDay,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _PickerRow(
                                icon: FontAwesomeIcons.calendarCheck,
                                label: t.accounts.dueDay,
                                value: _draft.dueDay?.toString() ??
                                    t.accounts.pickDueDay,
                                isPlaceholder: _draft.dueDay == null,
                                onTap: _pickDueDay,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PickerRow(
                          icon: FontAwesomeIcons.link,
                          label: t.accounts.linkedAccount,
                          value: _draft.linkedAccountName ??
                              t.accounts.pickLinkedAccount,
                          isPlaceholder: _draft.linkedAccountName == null,
                          onTap: _pickLinkedAccount,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            FinancoSubmitBar(
              label: t.general.save,
              onSubmit: _save,
              isEnabled: _isValid,
            ),
          ],
        ),
      ),
    );
  }
}

class _BankToggle extends StatelessWidget {
  const _BankToggle({required this.selected, required this.onChanged});

  final BankType selected;
  final ValueChanged<BankType> onChanged;

  @override
  Widget build(BuildContext context) {
    return FinancoPillToggle<BankType>(
      selected: selected,
      onChanged: onChanged,
      options: const [
        FinancoPillToggleOption(value: BankType.nubank, label: 'Nubank'),
        FinancoPillToggleOption(value: BankType.others, label: 'Others'),
      ],
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

class _LinkedAccountPicker extends StatelessWidget {
  const _LinkedAccountPicker({
    required this.candidates,
    required this.selectedName,
  });

  final List<String> candidates;
  final String? selectedName;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DraggableScrollableSheet(
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
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
                  t.accounts.pickLinkedAccount,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                itemCount: candidates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (_, i) {
                  final name = candidates[i];
                  final isSelected =
                      name.toLowerCase() == selectedName?.toLowerCase();
                  return Material(
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.pop(context, name),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.buildingColumns,
                              size: 14,
                              color: colors.onBackgroundLight,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: colors.onBackground,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              FaIcon(
                                FontAwesomeIcons.check,
                                size: 14,
                                color: colors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
