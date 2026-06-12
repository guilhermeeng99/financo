import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/app/widgets/import_widgets.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/import_accounts_csv_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// List of parsed CSV rows on the accounts import preview, filtered to
/// the selected [filter] type and sorted by name. Duplicates render at the
/// bottom, dimmed and non-interactive. Callbacks receive the row's index
/// in the *unfiltered* [items] list so the page can edit/remove the right
/// entry.
class AccountImportRowsList extends StatelessWidget {
  const AccountImportRowsList({
    required this.items,
    required this.duplicates,
    required this.filter,
    required this.onTap,
    required this.onRemove,
    super.key,
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
      (a, b) => a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase()),
    );

    final filteredDuplicates = duplicates
        .where((it) => it.type == filter)
        .toList();

    if (indexed.isEmpty && filteredDuplicates.isEmpty) {
      return ImportEmptyTab(message: t.accounts.importEmptyTab);
    }

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
                    ImportRemoveButton(onPressed: onRemove!),
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
