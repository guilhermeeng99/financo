import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Bottom sheet for picking an account on the transaction form. The label
/// adapts to the calling context — "Account", "Source account",
/// "Destination account" — and an optional `excludeId` hides one entry so
/// transfers can't accidentally pick the same account on both sides.
Future<String?> showTransactionAccountPicker({
  required BuildContext context,
  required String title,
  required String? selectedId,
  String? excludeId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _AccountPickerSheet(
      title: title,
      selectedId: selectedId,
      excludeId: excludeId,
    ),
  );
}

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({
    required this.title,
    required this.selectedId,
    required this.excludeId,
  });

  final String title;
  final String? selectedId;
  final String? excludeId;

  @override
  Widget build(BuildContext context) {
    final accounts = context
        .watch<AccountsCubit>()
        .state
        .accountsOrEmpty
        .where((a) => excludeId == null || a.id != excludeId)
        .toList();

    return FinancoPickerSheet(
      title: title,
      bodyBuilder: (scrollController) {
        if (accounts.isEmpty) {
          return FinancoPickerSheetEmpty(message: t.accounts.empty);
        }
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
          itemCount: accounts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (_, i) => _AccountRow(
            account: accounts[i],
            isSelected: accounts[i].id == selectedId,
            onTap: () => Navigator.pop(context, accounts[i].id),
          ),
        );
      },
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final AccountEntity account;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typeLabel = switch (account.type) {
      AccountType.creditCard => t.accounts.creditCard,
      AccountType.investment => t.accounts.investment,
      AccountType.checking => t.accounts.checking,
    };
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
              BankAvatar(bank: account.bank),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.name,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      typeLabel,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ],
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
