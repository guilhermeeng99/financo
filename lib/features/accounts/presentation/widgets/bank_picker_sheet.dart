import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
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

  /// Order surfaced to the user. "Outros" is anchored to the bottom so
  /// the picker reads as a list of named banks first, fallback last.
  static const _displayOrder = <BankType>[
    BankType.nubank,
    BankType.nuInvest,
    BankType.itau,
    BankType.bradesco,
    BankType.bancoDoBrasil,
    BankType.santander,
    BankType.caixa,
    BankType.inter,
    BankType.c6,
    BankType.btg,
    BankType.sicredi,
    BankType.sicoob,
    BankType.picpay,
    BankType.mercadoPago,
    BankType.pan,
    BankType.original,
    BankType.safra,
    BankType.xp,
    BankType.next,
    BankType.will,
    BankType.neon,
    BankType.others,
  ];

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
    final colors = context.appColors;
    final filtered = _filtered;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                  t.accounts.pickBank,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _SearchField(
              controller: _queryController,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const _EmptyResults()
                  : ListView.separated(
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: t.accounts.bankSearchHint,
          prefixIcon: SizedBox(
            width: 44,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 14,
                color: colors.onBackgroundLight,
              ),
            ),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 14,
                  color: colors.onBackgroundLight,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              );
            },
          ),
          filled: true,
          fillColor: colors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
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

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          t.accounts.bankSearchNoResults,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}
