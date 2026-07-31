import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/app/widgets/financo_picker_row.dart';
import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Picks the checking account that funded a buy or received a sell (F8.4 —
/// `docs/specs/investing_account_unification.md`).
///
/// The first row clears the choice, so a transaction can go back to "money
/// never left the broker" without reopening the form. Resolves to the picked
/// account id, an **empty string** for that clear row, or `null` when the sheet
/// is dismissed — the three cases the caller must tell apart.
///
/// ```dart
/// final picked = await showFundingAccountPicker(
///   context: context,
///   accounts: checkingAccounts,
///   selectedId: _fundingAccountId,
/// );
/// if (picked != null) setState(() => _id = picked.isEmpty ? null : picked);
/// ```
Future<String?> showFundingAccountPicker({
  required BuildContext context,
  required List<AccountEntity> accounts,
  required String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => FinancoPickerSheet(
      title: t.investing.transactions.funding,
      bodyBuilder: (scrollController) => ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        itemCount: accounts.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          if (i == 0) {
            return FinancoPickerRow(
              leading: const _NoAccountAvatar(),
              title: t.investing.transactions.fundingNone,
              isSelected: selectedId == null,
              onTap: () => Navigator.pop(sheetContext, ''),
            );
          }
          final account = accounts[i - 1];
          return FinancoPickerRow(
            leading: BankAvatar(bank: account.bank),
            title: account.name,
            subtitle: account.currency.code,
            isSelected: account.id == selectedId,
            onTap: () => Navigator.pop(sheetContext, account.id),
          );
        },
      ),
    ),
  );
}

/// Stand-in avatar for the "no account" row, sized to line up with the
/// [BankAvatar]s below it so the list reads as one column.
class _NoAccountAvatar extends StatelessWidget {
  const _NoAccountAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: FaIcon(
        FontAwesomeIcons.ban,
        size: 15,
        color: colors.onBackgroundLight,
      ),
    );
  }
}
