import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';

import 'package:financo/app/widgets/account_card.dart';
import 'package:financo/app/widgets/empty_state.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<AccountsCubit>().loadAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoAppBar(title: t.accounts.title),
      body: BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) {
          if (state is AccountsLoading) return const LoadingShimmer();
          if (state is AccountsError) {
            return ErrorView(
              message: state.failure.message,
              onRetry: () => context.read<AccountsCubit>().loadAccounts(
                forceRefresh: true,
              ),
            );
          }
          if (state is AccountsLoaded) {
            if (state.accounts.isEmpty) {
              return EmptyState(
                icon: FontAwesomeIcons.buildingColumns,
                message: t.accounts.empty,
              );
            }
            final checkings = state.accounts
                .where((a) => a.type == AccountType.checking)
                .toList();
            final creditCards = state.accounts
                .where((a) => a.type == AccountType.creditCard)
                .toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (checkings.isNotEmpty) ...[
                  _SectionHeader(title: t.accounts.checking),
                  ...checkings.map((a) => _AccountTile(account: a)),
                ],
                if (creditCards.isNotEmpty) ...[
                  if (checkings.isNotEmpty) const SizedBox(height: 16),
                  _SectionHeader(title: t.accounts.creditCard),
                  ...creditCards.map((a) => _AccountTile(account: a)),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'accounts_fab',
        onPressed: () async {
          final result = await context.push(AppRoutes.addAccount);
          if (result == true && context.mounted) {
            unawaited(
              context.read<AccountsCubit>().loadAccounts(
                forceRefresh: true,
              ),
            );
          }
        },
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.appColors.onBackgroundLight,
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account});

  final AccountEntity account;

  @override
  Widget build(BuildContext context) {
    return AccountCard(
      account: account,
      onTap: () async {
        final result = await context.push(
          AppRoutes.addAccount,
          extra: account,
        );
        if (result == true && context.mounted) {
          unawaited(
            context.read<AccountsCubit>().loadAccounts(forceRefresh: true),
          );
        }
      },
    );
  }
}
