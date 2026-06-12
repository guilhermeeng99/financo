import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/feature_empty_state.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_section_header.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/widgets/account_card.dart';
import 'package:financo/features/accounts/presentation/widgets/accounts_csv_import_dialog.dart';
import 'package:financo/features/investments/presentation/cubit/investments_cubit.dart';
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
    if (result == true && mounted) _refreshAfterAccountChange();
  }

  Future<void> _openEdit(AccountEntity account) async {
    final result = await context.push(AppRoutes.addAccount, extra: account);
    if (result == true && mounted) _refreshAfterAccountChange();
  }

  /// The add-account page lives on the root navigator, outside the shell's
  /// providers, so it can't touch shell-scoped cubits itself — it signals
  /// success via `pop(true)` and this page (inside the shell) refreshes.
  /// InvestmentsCubit is included so a deleted/created investment
  /// account's holdings drop in or out of the overview immediately.
  void _refreshAfterAccountChange() {
    unawaited(
      context.read<AccountsCubit>().loadAccounts(forceRefresh: true),
    );
    unawaited(
      context.read<InvestmentsCubit>().refresh(forceRefresh: true),
    );
  }

  Future<void> _openImport() => showAccountsCsvImportDialog(context);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.accounts.title,
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 4),
            child: FinancoAppBarIconButton(
              icon: FontAwesomeIcons.fileArrowUp,
              tooltip: t.accounts.importCsv,
              color: colors.primary,
              onPressed: () => unawaited(_openImport()),
            ),
          ),
        ],
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'accounts_fab',
          onPressed: _openAdd,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: BlocListener<AccountsCubit, AccountsState>(
        listener: (context, state) {
          if (state is AccountsImported) {
            context.showSnack(
              t.accounts.importSuccessDetailed(
                imported: state.importedCount,
                duplicates: state.duplicateCount,
              ),
            );
          }
        },
        child: BlocBuilder<AccountsCubit, AccountsState>(
          builder: (context, state) {
            if (state is AccountsLoading || state is AccountsImporting) {
              return const LoadingShimmer();
            }
            if (state is AccountsError) {
              return ErrorView(
                failure: state.failure,
                onRetry: () => context.read<AccountsCubit>().loadAccounts(
                  forceRefresh: true,
                ),
              );
            }
            final accounts = switch (state) {
              AccountsLoaded(:final accounts) => accounts,
              AccountsImported(:final accounts) => accounts,
              _ => const <AccountEntity>[],
            };
            if (accounts.isEmpty) {
              return FeatureEmptyState(
                icon: FontAwesomeIcons.buildingColumns,
                title: t.accounts.emptyTitle,
                message: t.accounts.emptySubtitle,
                actionLabel: t.accounts.addFirst,
                onAction: _openAdd,
              );
            }
            return _AccountsList(
              accounts: accounts,
              onTap: _openEdit,
            );
          },
        ),
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
    final investments = accounts
        .where((a) => a.type == AccountType.investment)
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
        if (investments.isNotEmpty) ...[
          FinancoSectionHeader(
            title: t.accounts.investment,
            count: investments.length,
            accent: colors.income,
          ),
          ...investments.map(
            (a) => AccountCard(account: a, onTap: () => onTap(a)),
          ),
        ],
      ],
    );
  }
}
