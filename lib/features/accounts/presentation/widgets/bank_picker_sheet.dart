import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/app/widgets/financo_search_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/string_normalize.dart';
import 'package:financo/features/accounts/domain/bank_brand.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Opens the bank picker as a draggable bottom sheet. Returns the
/// selected [BankType] or `null` when dismissed.
Future<BankType?> showBankPicker({
  required BuildContext context,
  required BankType selected,
}) {
  return showModalBottomSheet<BankType>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _BankPickerSheet(selected: selected),
  );
}

class _BankPickerSheet extends StatefulWidget {
  const _BankPickerSheet({required this.selected});

  final BankType selected;

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  final _queryController = TextEditingController();
  String _query = '';

  /// Order surfaced to the user: banks sorted alphabetically by label
  /// (accent-insensitive), with "Outros" anchored to the bottom as the
  /// catch-all fallback. Derived from [BankType] so new banks are placed
  /// automatically — no hand-maintained order to keep in sync.
  static final List<BankType> _displayOrder = _buildDisplayOrder();

  static List<BankType> _buildDisplayOrder() {
    final banks =
        BankType.values.where((b) => b != BankType.others).toList()
          ..sort(
            (a, b) => normalizeForMatch(
              BankBrand.of(a).label,
            ).compareTo(normalizeForMatch(BankBrand.of(b).label)),
          );
    return [...banks, BankType.others];
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<BankType> get _filtered {
    if (_query.trim().isEmpty) return _displayOrder;
    final resolved = BankBrand.resolveAlias(_query);
    if (resolved != null && _displayOrder.contains(resolved)) {
      // Move the alias hit to the top, keep the rest of the order.
      return [resolved, ..._displayOrder.where((b) => b != resolved)];
    }
    return _displayOrder.where((b) {
      final brand = BankBrand.of(b);
      return _matches(brand.label, _query);
    }).toList();
  }

  bool _matches(String haystack, String needle) {
    String norm(String s) => s
        .toLowerCase()
        .replaceAll(RegExp('[áàâãä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ç', 'c');
    return norm(haystack).contains(norm(needle));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return FinancoPickerSheet(
      title: t.accounts.pickBank,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      header: [
        FinancoSearchField(
          controller: _queryController,
          onChanged: (v) => setState(() => _query = v),
          hintText: t.accounts.bankSearchHint,
        ),
        const SizedBox(height: 8),
      ],
      bodyBuilder: (scrollController) {
        if (filtered.isEmpty) {
          return FinancoPickerSheetEmpty(
            message: t.accounts.bankSearchNoResults,
          );
        }
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (_, i) {
            final bank = filtered[i];
            return _BankRow(
              bank: bank,
              isSelected: bank == widget.selected,
              onTap: () => Navigator.pop(context, bank),
            );
          },
        );
      },
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({
    required this.bank,
    required this.isSelected,
    required this.onTap,
  });

  final BankType bank;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final brand = BankBrand.of(bank);
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              BankAvatar(bank: bank),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  brand.label,
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
  }
}
