import 'package:financo/app/widgets/financo_currency_field.dart';
import 'package:financo/app/widgets/financo_form_section.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/amount_parser.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/widgets/bank_picker_field.dart';
import 'package:financo/features/accounts/presentation/widgets/day_picker_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Per-row edit sheet of the accounts import preview. Pops with the edited
/// [AccountImportPreviewItem], or `null` when dismissed. Switching type
/// clears the conditional fields: going checking → credit card requires
/// the user to fill credit-limit, closing/due day, and pick a linked
/// checking account; going credit card → checking drops all of them.
///
/// ```dart
/// final edited = await showModalBottomSheet<AccountImportPreviewItem>(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => AccountImportEditSheet(
///     item: item,
///     otherCheckingNames: names,
///   ),
/// );
/// ```
class AccountImportEditSheet extends StatefulWidget {
  const AccountImportEditSheet({
    required this.item,
    required this.otherCheckingNames,
    super.key,
  });

  final AccountImportPreviewItem item;

  /// Checking accounts being imported in this batch (excluding the
  /// currently-edited row), used to populate the linked-account picker
  /// alongside any existing checking accounts.
  final List<String> otherCheckingNames;

  @override
  State<AccountImportEditSheet> createState() => _AccountImportEditSheetState();
}

class _AccountImportEditSheetState extends State<AccountImportEditSheet> {
  late AccountImportPreviewItem _draft;
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _draft = widget.item;
    _nameController = TextEditingController(text: _draft.name);
    // Seed the controllers with BR-formatted text so the first paint
    // matches what `BrlCurrencyInputFormatter` produces on edit.
    _balanceController = TextEditingController(
      text: BrlCurrencyInputFormatter.format(_draft.initialBalance),
    );
    _limitController = TextEditingController(
      // Show whatever the CSV gave us (including 0,00) so the user can see
      // the field is "set but invalid" instead of just empty placeholder.
      text: _draft.creditLimit != null
          ? BrlCurrencyInputFormatter.format(_draft.creditLimit!)
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
    final existing = context
        .read<AccountsCubit>()
        .state
        .accountsOrEmpty
        .where((a) => a.type == AccountType.checking)
        .map((a) => a.name)
        .toList();

    final candidates = <String>{
      ...existing,
      ...widget.otherCheckingNames,
    }.toList();
    if (candidates.isEmpty) {
      context.showSnack(t.accounts.noLinkedCandidates);
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

  /// Returns the localized labels for fields the user still has to fill.
  /// Used both to gate the Save button (`isEmpty`) and to spell out the
  /// reason in a snackbar when the user taps Save anyway.
  List<String> _missingFields() {
    final missing = <String>[];
    if (_nameController.text.trim().isEmpty) {
      missing.add(t.accounts.name);
    }
    if (_draft.isCreditCard) {
      final limit = parseDecimalAmount(_limitController.text);
      if (limit == null || limit <= 0) missing.add(t.accounts.creditLimit);
      if (_draft.closingDay == null) missing.add(t.accounts.closingDay);
      if (_draft.dueDay == null) missing.add(t.accounts.dueDay);
      if (_draft.linkedAccountName == null ||
          _draft.linkedAccountName!.isEmpty) {
        missing.add(t.accounts.linkedAccount);
      }
    }
    return missing;
  }

  void _save() {
    final missing = _missingFields();
    if (missing.isNotEmpty) {
      context.showSnack(
        t.accounts.importMissingFields(fields: missing.join(', ')),
      );
      return;
    }
    final balance = parseDecimalAmount(_balanceController.text) ?? 0;
    final limit = parseDecimalAmount(_limitController.text) ?? 0;
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
                      FinancoCurrencyField(
                        controller: _balanceController,
                        label: t.accounts.balanceLabel,
                        hintText: t.accounts.balanceHint,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      BankPickerField(
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
                        FinancoCurrencyField(
                          controller: _limitController,
                          label: t.accounts.creditLimitLabel,
                          hintText: t.accounts.creditLimitHint,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ImportPickerRow(
                                icon: FontAwesomeIcons.calendar,
                                label: t.accounts.closingDay,
                                value:
                                    _draft.closingDay?.toString() ??
                                    t.accounts.pickClosingDay,
                                isPlaceholder: _draft.closingDay == null,
                                onTap: _pickClosingDay,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ImportPickerRow(
                                icon: FontAwesomeIcons.calendarCheck,
                                label: t.accounts.dueDay,
                                value:
                                    _draft.dueDay?.toString() ??
                                    t.accounts.pickDueDay,
                                isPlaceholder: _draft.dueDay == null,
                                onTap: _pickDueDay,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ImportPickerRow(
                          icon: FontAwesomeIcons.link,
                          label: t.accounts.linkedAccount,
                          value:
                              _draft.linkedAccountName ??
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
