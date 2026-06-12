import 'dart:async';

import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

/// Bottom sheet that lists the user's checking accounts so a credit card
/// can be linked to one. Replaces the stock `DropdownButtonFormField`.
///
/// Returns the picked [AccountEntity] (or null if dismissed). Returning the
/// whole entity — instead of just the id — lets the caller render the name
/// without re-querying for it, which matters for the add-account page that
/// is mounted outside the shell's `AccountsCubit` scope.
Future<AccountEntity?> showLinkedAccountPicker({
  required BuildContext context,
  required String userId,
  required String? selectedId,
}) {
  return showModalBottomSheet<AccountEntity>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) =>
        _LinkedAccountPickerSheet(userId: userId, selectedId: selectedId),
  );
}

class _LinkedAccountPickerSheet extends StatefulWidget {
  const _LinkedAccountPickerSheet({
    required this.userId,
    required this.selectedId,
  });

  final String userId;
  final String? selectedId;

  @override
  State<_LinkedAccountPickerSheet> createState() =>
      _LinkedAccountPickerSheetState();
}

class _LinkedAccountPickerSheetState
    extends State<_LinkedAccountPickerSheet> {
  List<AccountEntity>? _accounts;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  /// Loads via the use case instead of watching `AccountsCubit`: the
  /// add-account page (this sheet's only caller) is mounted on the root
  /// navigator, outside the shell's cubit scope, so the cubit is not
  /// available here.
  Future<void> _load() async {
    final result = await GetIt.I<GetAccountsUseCase>()(userId: widget.userId);
    if (!mounted) return;
    setState(() {
      _accounts = result.fold(
        (_) => <AccountEntity>[],
        (all) =>
            all.where((a) => a.type == AccountType.checking).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _accounts;
    return FinancoPickerSheet(
      title: t.accounts.pickLinkedAccount,
      bodyBuilder: (scrollController) {
        if (accounts == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (accounts.isEmpty) {
          return FinancoPickerSheetEmpty(
            message: t.accounts.noLinkedCandidates,
          );
        }
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
          itemCount: accounts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (_, i) => _AccountRow(
            account: accounts[i],
            isSelected: accounts[i].id == widget.selectedId,
            onTap: () => Navigator.pop(context, accounts[i]),
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
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              BankAvatar(bank: account.bank),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
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
