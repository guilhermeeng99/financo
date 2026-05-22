import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_month_filter_pill.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/responsive_layout.dart';
import 'package:financo/app/widgets/transaction_tile.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/account_statement_cubit.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/accounts/presentation/widgets/account_balance_card.dart';
import 'package:financo/features/accounts/presentation/widgets/account_detail_section.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AccountStatementPage extends StatefulWidget {
  const AccountStatementPage({required this.accountId, super.key});

  final String accountId;

  @override
  State<AccountStatementPage> createState() => _AccountStatementPageState();
}

class _AccountStatementPageState extends State<AccountStatementPage> {
  AccountEntity? _account;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final account = context
          .read<AccountsCubit>()
          .state
          .accountsOrEmpty
          .where((a) => a.id == widget.accountId)
          .firstOrNull;
      if (account != null) _triggerLoad(account);
    });
  }

  void _triggerLoad(AccountEntity account) {
    _account = account;
    final filter = context.read<DateFilterCubit>().state;
    unawaited(
      context.read<AccountStatementCubit>().load(
        account,
        filter.year,
        filter.month,
      ),
    );
  }

  Future<void> _openAddTransaction() async {
    // Same destination as the dashboard FAB, but pre-selects this account
    // via a query param so users don't re-pick the account they're
    // already viewing.
    await context.push<Object?>(
      '${AppRoutes.addTransaction}?accountId=${widget.accountId}',
    );
    if (!mounted || _account == null) return;
    _triggerLoad(_account!);
  }

  /// Reloads the statement after edit/delete just like [_openAddTransaction]
  /// does for create — without this, mutations performed on the add/edit
  /// transaction page only show up on the next entry into this page, since
  /// `AccountStatementCubit` is not subscribed to `TransactionsBloc`.
  Future<void> _openEditTransaction(TransactionEntity tx) async {
    await context.push<Object?>(AppRoutes.addTransaction, extra: tx);
    if (!mounted || _account == null) return;
    _triggerLoad(_account!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'account_statement_fab',
          onPressed: _openAddTransaction,
          tooltip: t.transactions.addTransaction,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: MultiBlocListener(
          listeners: [
            BlocListener<AccountsCubit, AccountsState>(
              listener: (context, state) {
                final account = state.accountsOrEmpty
                    .where((a) => a.id == widget.accountId)
                    .firstOrNull;
                if (account != null && account != _account) {
                  _triggerLoad(account);
                }
              },
            ),
            BlocListener<DateFilterCubit, DateFilterState>(
              listener: (context, filter) {
                if (_account != null) {
                  unawaited(
                    context.read<AccountStatementCubit>().load(
                      _account!,
                      filter.year,
                      filter.month,
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<AccountStatementCubit, AccountStatementState>(
            builder: (context, state) {
              if (state is AccountStatementLoading ||
                  state is AccountStatementInitial) {
                return const LoadingShimmer();
              }
              if (state is AccountStatementError) {
                return ErrorView(
                  failure: state.failure,
                  onRetry: () {
                    if (_account != null) _triggerLoad(_account!);
                  },
                );
              }
              if (state is AccountStatementLoaded) {
                return _StatementContent(
                  state: state,
                  onTransactionTap: _openEditTransaction,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _StatementContent extends StatelessWidget {
  const _StatementContent({
    required this.state,
    required this.onTransactionTap,
  });

  final AccountStatementLoaded state;
  final ValueChanged<TransactionEntity> onTransactionTap;

  static const _kWideBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenSize.width >= _kWideBreakpoint;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 360,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              child: _SummarySide(state: state),
            ),
          ),
          Container(
            width: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 24),
            color: context.appColors.surfaceVariant,
          ),
          Expanded(
            child: _TransactionsSide(
              state: state,
              onTransactionTap: onTransactionTap,
            ),
          ),
        ],
      );
    }

    // Header stays pinned; only the transactions list scrolls — keeps the
    // account balance and monthly summary always visible while the user
    // skims a long transactions list.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _SummarySide(state: state),
        ),
        Expanded(
          child: _TransactionsSide(
            state: state,
            onTransactionTap: onTransactionTap,
          ),
        ),
      ],
    );
  }
}

class _SummarySide extends StatelessWidget {
  const _SummarySide({required this.state});

  final AccountStatementLoaded state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final account = state.account;
    final isMobile = ResponsiveLayout.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back chip — kept here (not in an AppBar) because the page sits
        // inside the shell scaffold and a top bar would double the
        // navigation chrome. On mobile we also center the month filter pill
        // in the same row (sidebar hosts its own stepper on tablet/web).
        if (isMobile)
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _BackChip(
                  onTap: () => context.go(AppRoutes.dashboard),
                ),
              ),
              const FinancoMonthFilterPill(),
            ],
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: _BackChip(
              onTap: () => context.go(AppRoutes.dashboard),
            ),
          ),
        const SizedBox(height: 16),
        AccountBalanceCard(
          account: account,
          balance: state.runningBalance,
          // On mobile, fold limit/closing/due into the hero card so the
          // transactions list keeps most of the viewport. The standalone
          // CREDIT CARD section was eating ~280dp of scroll height for
          // info that's reference-only, making the list itself feel
          // unusable (one tx visible at a time on small phones).
          showCreditMeta:
              isMobile && account.type == AccountType.creditCard,
        ),
        const SizedBox(height: 20),
        AccountDetailSection(
          label: t.accounts.statement,
          rows: [
            _SummaryRow(
              label: t.accounts.monthIncome,
              amount: state.totalIncome,
              color: colors.income,
            ),
            _SummaryRow(
              label: t.accounts.monthExpenses,
              amount: -state.totalExpenses,
              color: colors.expense,
            ),
            _SummaryRow(
              label: t.accounts.monthResult,
              amount: state.result,
              color: state.result >= 0 ? colors.income : colors.expense,
              bold: true,
            ),
          ],
        ),
        if (account.type == AccountType.creditCard && !isMobile) ...[
          const SizedBox(height: 20),
          AccountDetailSection(
            label: t.accounts.creditCard,
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
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.chevronLeft,
                size: 11,
                color: colors.onBackgroundLight,
              ),
              const SizedBox(width: 8),
              Text(
                t.nav.dashboard,
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.color,
    this.bold = false,
  });

  final String label;
  final double amount;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return AccountDetailRow(
      label: label,
      child: AmountText(
        amount: amount,
        fontSize: bold ? 16 : 14,
      ),
    );
  }
}

class _TransactionsSide extends StatelessWidget {
  const _TransactionsSide({
    required this.state,
    required this.onTransactionTap,
  });

  final AccountStatementLoaded state;
  final ValueChanged<TransactionEntity> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final categoryMap = {
      for (final c in context.watch<CategoriesCubit>().state.categoriesOrEmpty)
        c.id: c,
    };
    final accountMap = {
      for (final a in context.watch<AccountsCubit>().state.accountsOrEmpty)
        a.id: a,
    };

    if (state.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            t.accounts.noTransactionsInPeriod,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final tx = state.transactions[index];
        final label = tx.isTransfer
            ? _transferLabel(tx, accountMap)
            : _categoryLabel(categoryMap, tx.categoryId);
        return TransactionTile(
          transaction: tx,
          categoryLabel: label,
          // Awaited via the parent so the statement reloads after edit
          // or delete; `context.push` directly would not refresh.
          onTap: () => onTransactionTap(tx),
        );
      },
    );
  }

  String? _categoryLabel(
    Map<String, CategoryEntity> categoryMap,
    String categoryId,
  ) {
    if (categoryId.isEmpty) return null;
    final category = categoryMap[categoryId];
    if (category == null) return null;
    if (category.parentId != null) {
      final parent = categoryMap[category.parentId];
      if (parent != null) return '${parent.name} › ${category.name}';
    }
    return category.name;
  }

  String? _transferLabel(
    TransactionEntity tx,
    Map<String, AccountEntity> accountMap,
  ) {
    final thisAccount = accountMap[tx.accountId];
    final otherAccountId = state.transferCounterpartAccountIds[tx.id];
    final otherAccount = otherAccountId != null
        ? accountMap[otherAccountId]
        : null;
    if (thisAccount == null || otherAccount == null) return null;
    return tx.type == TransactionType.income
        ? '${otherAccount.name} → ${thisAccount.name}'
        : '${thisAccount.name} → ${otherAccount.name}';
  }
}
