import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/transaction_tile.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/account_statement_cubit.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
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
    // Trigger load after first frame so context is fully available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final accountsState = context.read<AccountsCubit>().state;
      if (accountsState is AccountsLoaded) {
        final account = accountsState.accounts
            .where((a) => a.id == widget.accountId)
            .firstOrNull;
        if (account != null) _triggerLoad(account);
      }
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // AccountsCubit becomes ready (e.g. after auth completes)
        BlocListener<AccountsCubit, AccountsState>(
          listener: (context, state) {
            if (state is AccountsLoaded) {
              final account = state.accounts
                  .where((a) => a.id == widget.accountId)
                  .firstOrNull;
              if (account != null && account != _account) {
                _triggerLoad(account);
              }
            }
          },
        ),
        // Sidebar month/year changed
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
              message: state.failure.message,
              onRetry: () {
                if (_account != null) _triggerLoad(_account!);
              },
            );
          }
          if (state is AccountStatementLoaded) {
            return _StatementContent(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatementContent extends StatelessWidget {
  const _StatementContent({required this.state});

  final AccountStatementLoaded state;

  // Breakpoint: below this width, switch to single-column layout
  static const _kWideBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenSize.width >= _kWideBreakpoint;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: _SummaryPanel(state: state),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _TransactionsPanel(state: state),
          ),
        ],
      );
    }

    // Mobile: single scrollable column
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _SummaryPanel(state: state)),
        const SliverToBoxAdapter(child: Divider(height: 1)),
        SliverFillRemaining(
          child: _TransactionsPanel(state: state),
        ),
      ],
    );
  }
}

// ─── Left panel: account info + financial summary ────────────
class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.state});

  final AccountStatementLoaded state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final account = state.account;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Back button + title ───────────────────────────
          Row(
            children: [
              IconButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 18),
                tooltip: t.nav.dashboard,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  account.name,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              _accountSubtitle(account),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Current balance ───────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    t.accounts.currentBalance,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AmountText(amount: state.runningBalance, fontSize: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Monthly summary ───────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.accounts.statement,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: t.accounts.monthIncome,
                    amount: state.totalIncome,
                    icon: FontAwesomeIcons.arrowUp,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: t.accounts.monthExpenses,
                    amount: -state.totalExpenses,
                    icon: FontAwesomeIcons.arrowDown,
                  ),
                  const Divider(height: 20),
                  _SummaryRow(
                    label: t.accounts.monthResult,
                    amount: state.result,
                    icon: FontAwesomeIcons.equals,
                    bold: true,
                  ),
                ],
              ),
            ),
          ),

          // ─── Credit card details ───────────────────────────
          if (account.type == AccountType.creditCard) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.accounts.creditCard,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: t.accounts.creditLimit,
                      child: AmountText(
                        amount: account.creditLimit ?? 0,
                        fontSize: 14,
                      ),
                    ),
                    _DetailRow(
                      label: t.accounts.availableCredit,
                      child: AmountText(
                        amount: account.availableCredit,
                        fontSize: 14,
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
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _accountSubtitle(AccountEntity account) {
    final type = account.type == AccountType.checking
        ? t.accounts.checking
        : t.accounts.creditCard;
    return '$type • ${account.bankLabel}';
  }
}

// ─── Right panel: transaction list ───────────────────────────
class _TransactionsPanel extends StatelessWidget {
  const _TransactionsPanel({required this.state});

  final AccountStatementLoaded state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final categoriesState = context.watch<CategoriesCubit>().state;
    final categoryMap = categoriesState is CategoriesLoaded
        ? {for (final c in categoriesState.categories) c.id: c}
        : <String, CategoryEntity>{};

    final accountsState = context.watch<AccountsCubit>().state;
    final accountMap = accountsState is AccountsLoaded
        ? {for (final a in accountsState.accounts) a.id: a}
        : <String, AccountEntity>{};

    if (state.transactions.isEmpty) {
      return Center(
        child: Text(
          t.accounts.noTransactionsInPeriod,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.transactions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = state.transactions[index];
        final label = tx.isTransfer
            ? _transferLabel(tx, accountMap)
            : _categoryLabel(categoryMap, tx.categoryId);
        return TransactionTile(
          transaction: tx,
          categoryLabel: label,
          onTap: () => context.go(
            AppRoutes.addTransaction,
            extra: tx,
          ),
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
    final otherAccount =
        otherAccountId != null ? accountMap[otherAccountId] : null;

    if (thisAccount == null || otherAccount == null) return null;

    // Income into this account → money came FROM the other account.
    // Expense from this account → money went TO the other account.
    return tx.type == TransactionType.income
        ? '${otherAccount.name} → ${thisAccount.name}'
        : '${thisAccount.name} → ${otherAccount.name}';
  }
}

// ─── Summary row ─────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.icon,
    this.bold = false,
  });

  final String label;
  final double amount;
  final FaIconData icon;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: context.appColors.onBackgroundLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        AmountText(amount: amount, fontSize: 14),
      ],
    );
  }
}

// ─── Detail row ──────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.appColors.onBackgroundLight,
            ),
          ),
          child ?? Text(value ?? '', style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
