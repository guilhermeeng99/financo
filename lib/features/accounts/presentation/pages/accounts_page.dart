import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_section_header.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/widgets/account_card.dart';
import 'package:financo/features/accounts/presentation/widgets/accounts_empty_state.dart';
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

  Future<void> _openAdd() async {
    final result = await context.push(AppRoutes.addAccount);
    if (result == true && mounted) {
      unawaited(
        context.read<AccountsCubit>().loadAccounts(forceRefresh: true),
      );
    }
  }

  Future<void> _openEdit(AccountEntity account) async {
    final result = await context.push(AppRoutes.addAccount, extra: account);
    if (result == true && mounted) {
      unawaited(
        context.read<AccountsCubit>().loadAccounts(forceRefresh: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(title: t.accounts.title, showBack: true),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'accounts_fab',
          onPressed: _openAdd,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) {
          if (state is AccountsLoading) return const LoadingShimmer();
          if (state is AccountsError) {
            return ErrorView(
              message: state.failure.message,
              onRetry: () => context
                  .read<AccountsCubit>()
                  .loadAccounts(forceRefresh: true),
            );
          }
          if (state is AccountsLoaded) {
            if (state.accounts.isEmpty) {
              return AccountsEmptyState(onAddPressed: _openAdd);
            }
            return _AccountsList(
              accounts: state.accounts,
              onTap: _openEdit,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AccountsList extends StatelessWidget {
  const _AccountsList({required this.accounts, required this.onTap});

  final List<AccountEntity> accounts;
  final void Function(AccountEntity) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final checkings = accounts
        .where((a) => a.type == AccountType.checking)
        .toList();
    final creditCards = accounts
        .where((a) => a.type == AccountType.creditCard)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (checkings.isNotEmpty) ...[
          FinancoSectionHeader(
            title: t.accounts.checking,
            count: checkings.length,
            accent: colors.primary,
          ),
          ...checkings.map(
            (a) => AccountCard(account: a, onTap: () => onTap(a)),
          ),
        ],
        if (creditCards.isNotEmpty) ...[
          FinancoSectionHeader(
            title: t.accounts.creditCard,
            count: creditCards.length,
            accent: colors.warning,
          ),
          ...creditCards.map(
            (a) => AccountCard(account: a, onTap: () => onTap(a)),
          ),
        ],
      ],
    );
  }
}
