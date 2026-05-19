import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/widgets/account_balance_card.dart';
import 'package:financo/features/accounts/presentation/widgets/account_detail_section.dart';
import 'package:financo/features/investments/presentation/cubit/investments_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({required this.accountId, super.key});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final accounts = state.accountsOrEmpty;
        final account = accounts.where((a) => a.id == accountId).firstOrNull;

        if (account == null) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: _buildAppBar(context, t.accounts.account),
            body: Center(child: Text(t.accounts.accountNotFound)),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          appBar: _buildAppBar(
            context,
            account.name,
            account: account,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              AccountBalanceCard(
                account: account,
                balance: account.type == AccountType.creditCard
                    ? account.availableCredit
                    : account.effectiveBalance,
              ),
              const SizedBox(height: 24),
              AccountDetailSection(
                label: t.accounts.formSectionDetails,
                rows: [
                  AccountDetailRow(
                    label: t.accounts.type,
                    value: account.type == AccountType.checking
                        ? t.accounts.checking
                        : t.accounts.creditCard,
                  ),
                  AccountDetailRow(
                    label: t.accounts.bank,
                    value: account.bankLabel,
                  ),
                  if (account.type == AccountType.creditCard &&
                      account.linkedAccountId != null)
                    AccountDetailRow(
                      label: t.accounts.linkedAccount,
                      value: accounts
                              .where(
                                (a) => a.id == account.linkedAccountId,
                              )
                              .firstOrNull
                              ?.name ??
                          '—',
                    ),
                ],
              ),
              if (account.type == AccountType.creditCard) ...[
                const SizedBox(height: 20),
                AccountDetailSection(
                  label: t.accounts.formSectionCreditCard,
                  rows: [
                    AccountDetailRow(
                      label: t.accounts.creditLimit,
                      value: formatCurrency(account.creditLimit ?? 0),
                    ),
                    AccountDetailRow(
                      label: t.accounts.availableCredit,
                      value: formatCurrency(account.availableCredit),
                    ),
                    AccountDetailRow(
                      label: t.accounts.closingDay,
                      value: '${account.closingDay ?? '-'}',
                    ),
                    AccountDetailRow(
                      label: t.accounts.dueDay,
                      value: '${account.dueDay ?? '-'}',
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    String title, {
    AccountEntity? account,
  }) {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          color: colors.onBackground,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: account == null
          ? null
          : [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _AppBarIconButton(
                  icon: FontAwesomeIcons.penToSquare,
                  color: colors.primary,
                  tooltip: t.general.edit,
                  onPressed: () =>
                      unawaited(_openEdit(context, account)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _AppBarIconButton(
                  icon: FontAwesomeIcons.trash,
                  color: colors.error,
                  tooltip: t.general.delete,
                  onPressed: () =>
                      unawaited(_confirmDelete(context, account)),
                ),
              ),
            ],
    );
  }

  Future<void> _openEdit(BuildContext context, AccountEntity account) async {
    final result = await context.push(AppRoutes.addAccount, extra: account);
    if (result == true && context.mounted) {
      unawaited(
        context.read<AccountsCubit>().loadAccounts(forceRefresh: true),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AccountEntity account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.general.delete),
        content: Text(t.accounts.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.general.delete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await GetIt.I<DeleteAccountUseCase>()(account.id);
    if (!context.mounted) return;
    // Cascade-delete investment holdings tied to this account
    // (rule 6 of specs/investments.md). Best-effort.
    unawaited(
      context.read<InvestmentsCubit>().removeHoldingsForAccount(account.id),
    );
    context.pop(true);
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  final FaIconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(child: FaIcon(icon, size: 14, color: color)),
          ),
        ),
      ),
    );
  }
}
