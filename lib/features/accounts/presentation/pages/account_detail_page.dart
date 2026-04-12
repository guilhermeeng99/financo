import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({required this.accountId, super.key});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        AccountEntity? account;
        if (state is AccountsLoaded) {
          account = state.accounts.where((a) => a.id == accountId).firstOrNull;
        }

        if (account == null) {
          return Scaffold(
            appBar: AppBar(title: Text(t.accounts.account)),
            body: Center(child: Text(t.accounts.accountNotFound)),
          );
        }

        final currentAccount = account;

        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await context.push(
                      AppRoutes.addAccount,
                      extra: account,
                    );
                    if (result == true && context.mounted) {
                      unawaited(
                        context.read<AccountsCubit>().loadAccounts(
                          forceRefresh: true,
                        ),
                      );
                    }
                  } else if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(t.general.delete),
                        content: Text(
                          t.accounts.deleteConfirm,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(t.general.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(t.general.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      final deleteAccount = GetIt.I<DeleteAccountUseCase>();
                      await deleteAccount(currentAccount.id);
                      if (context.mounted) context.pop(true);
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(t.general.edit),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(t.general.delete),
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: AmountText(
                    amount: account.initialBalance,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    t.accounts.currentBalance,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _DetailRow(
                  label: t.accounts.type,
                  value: account.type == AccountType.checking
                      ? t.accounts.checking
                      : t.accounts.creditCard,
                ),
                _DetailRow(
                  label: t.accounts.bank,
                  value: account.bankLabel,
                ),
                if (account.type == AccountType.creditCard) ...[
                  if (account.linkedAccountId != null &&
                      state is AccountsLoaded) ...[
                    Builder(
                      builder: (context) {
                        final linked = state.accounts
                            .where(
                              (a) => a.id == currentAccount.linkedAccountId,
                            )
                            .firstOrNull;
                        if (linked == null) return const SizedBox.shrink();
                        return _DetailRow(
                          label: t.accounts.linkedAccount,
                          value: linked.name,
                        );
                      },
                    ),
                  ],
                  _DetailRow(
                    label: t.accounts.creditLimit,
                    child: AmountText(
                      amount: account.creditLimit ?? 0,
                      fontSize: 16,
                    ),
                  ),
                  _DetailRow(
                    label: t.accounts.availableCredit,
                    child: AmountText(
                      amount: account.availableCredit,
                      fontSize: 16,
                    ),
                  ),
                  _DetailRow(
                    label: t.accounts.closingDay,
                    value: '${account.closingDay}',
                  ),
                  _DetailRow(
                    label: t.accounts.dueDay,
                    value: '${account.dueDay}',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child:
                child ?? Text(value ?? '', style: context.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
