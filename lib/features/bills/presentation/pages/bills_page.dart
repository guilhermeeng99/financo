import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_month_filter_pill.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/app/widgets/financo_section_header.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/responsive_layout.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/errors/failures.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/accounts/domain/bank_brand.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:financo/features/transactions/domain/usecases/settle_transaction_usecase.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

enum PayablesReceivablesView { payables, receivables, paid, received }

class BillsPage extends StatefulWidget {
  const BillsPage({
    super.key,
    this.embedded = false,
    this.initialView = PayablesReceivablesView.payables,
    this.availableViews = const [
      PayablesReceivablesView.payables,
      PayablesReceivablesView.receivables,
      PayablesReceivablesView.paid,
      PayablesReceivablesView.received,
    ],
  });

  final bool embedded;
  final PayablesReceivablesView initialView;
  final List<PayablesReceivablesView> availableViews;

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late PayablesReceivablesView _view;
  Future<_BillsSnapshot>? _future;
  Set<String> _selectedAccountIds = <String>{};

  String get _userId {
    final authState = context.read<AuthBloc>().state;
    return authState is Authenticated ? authState.user.id : '';
  }

  @override
  void initState() {
    super.initState();
    _view = widget.initialView;
    _future = _load(forceRefresh: true);
  }

  @override
  void didUpdateWidget(covariant BillsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialView != widget.initialView) {
      _view = widget.initialView;
    }
  }

  Future<_BillsSnapshot> _load({bool forceRefresh = false}) async {
    final filter = context.read<DateFilterCubit>().state;
    final month = DateTime(filter.year, filter.month);
    final result = await GetIt.I<GetTransactionsUseCase>()(
      userId: _userId,
      endDate: endOfMonth(month),
      forceRefresh: forceRefresh,
    );
    return result.fold(
      (failure) => throw _SnapshotLoadException(failure),
      (transactions) => _BillsSnapshot(
        month: month,
        transactions: transactions.where((tx) => !tx.isTransfer).toList(),
      ),
    );
  }

  void _refresh({bool forceRefresh = false}) {
    setState(() {
      _future = _load(forceRefresh: forceRefresh);
    });
  }

  void _toggleAccountFilter(
    String accountId,
    List<String> availableAccountIds,
  ) {
    final available = availableAccountIds.toSet();
    if (available.isEmpty) return;

    setState(() {
      final selected = _selectedAccountIds.isEmpty
          ? available
          : _selectedAccountIds.where(available.contains).toSet();
      if (selected.contains(accountId)) {
        selected.remove(accountId);
      } else {
        selected.add(accountId);
      }
      _selectedAccountIds =
          selected.isEmpty || selected.length == available.length
          ? <String>{}
          : selected;
    });
  }

  Future<void> _openAddTransaction() async {
    await context.push(AppRoutes.addTransaction);
    if (mounted) _refresh(forceRefresh: true);
  }

  Future<void> _openTransaction(TransactionEntity transaction) async {
    await context.push(AppRoutes.addTransaction, extra: transaction);
    if (mounted) _refresh(forceRefresh: true);
  }

  Future<void> _settle(TransactionEntity transaction) async {
    final result = await GetIt.I<SettleTransactionUseCase>()(transaction);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedFailure(failure))),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transaction.isReceivable
                  ? t.bills.transactionReceived
                  : t.bills.transactionPaid,
            ),
          ),
        );
        _refreshDependents();
        _refresh(forceRefresh: true);
      },
    );
  }

  Future<void> _delete(TransactionEntity transaction) async {
    final confirmed = await showFinancoConfirmDialog(
      context,
      icon: FontAwesomeIcons.trashCan,
      title: t.general.delete,
      message: t.transactions.deleteConfirm,
      confirmLabel: t.general.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final result = await GetIt.I<DeleteTransactionUseCase>()(transaction.id);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedFailure(failure))),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.transactions.deleted)),
        );
        _refreshDependents();
        _refresh(forceRefresh: true);
      },
    );
  }

  void _refreshDependents() {
    context.read<TransactionsBloc>().add(
      TransactionsLoadRequested(forceRefresh: true),
    );
    context.read<DashboardBloc>().add(const DashboardRefreshRequested());
    unawaited(context.read<AccountsCubit>().loadAccounts(forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DateFilterCubit, DateFilterState>(
      listener: (context, _) => _refresh(forceRefresh: true),
      child: Scaffold(
        appBar: widget.embedded
            ? null
            : FinancoLargeAppBar(
                title: _pageTitle,
              ),
        floatingActionButton: LiftedFab(
          child: FloatingActionButton(
            heroTag: widget.embedded ? 'embedded_bills_fab' : 'bills_fab',
            onPressed: _openAddTransaction,
            child: const Icon(Icons.add),
          ),
        ),
        body: FutureBuilder<_BillsSnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingShimmer();
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              final failure = error is _SnapshotLoadException
                  ? error.failure
                  : const ServerFailure();
              return ErrorView(
                failure: failure,
                onRetry: () => _refresh(forceRefresh: true),
              );
            }
            final data = snapshot.data!;
            return _BillsContent(
              snapshot: data,
              view: _view,
              onViewChanged: (view) => setState(() => _view = view),
              onAdd: _openAddTransaction,
              onOpen: _openTransaction,
              onSettle: _settle,
              onDelete: _delete,
              embedded: widget.embedded,
              availableViews: widget.availableViews,
              selectedAccountIds: _selectedAccountIds,
              onAccountToggled: _toggleAccountFilter,
            );
          },
        ),
      ),
    );
  }

  String get _pageTitle {
    if (_isSettledMode(widget.availableViews)) return t.nav.paidAndReceived;
    return t.nav.payablesReceivables;
  }
}

class _BillsContent extends StatelessWidget {
  const _BillsContent({
    required this.snapshot,
    required this.view,
    required this.onViewChanged,
    required this.onAdd,
    required this.onOpen,
    required this.onSettle,
    required this.onDelete,
    required this.embedded,
    required this.availableViews,
    required this.selectedAccountIds,
    required this.onAccountToggled,
  });

  final _BillsSnapshot snapshot;
  final PayablesReceivablesView view;
  final ValueChanged<PayablesReceivablesView> onViewChanged;
  final VoidCallback onAdd;
  final void Function(TransactionEntity) onOpen;
  final void Function(TransactionEntity) onSettle;
  final void Function(TransactionEntity) onDelete;
  final bool embedded;
  final List<PayablesReceivablesView> availableViews;
  final Set<String> selectedAccountIds;
  final void Function(String accountId, List<String> availableAccountIds)
  onAccountToggled;

  @override
  Widget build(BuildContext context) {
    final allVisible = snapshot.visibleFor(view);
    final visible = _filterByAccounts(allVisible, selectedAccountIds);
    final summary = _BillsSummary.from(
      _filterByAccounts(
        snapshot.visibleFor(PayablesReceivablesView.payables),
        selectedAccountIds,
      ),
      _filterByAccounts(
        snapshot.visibleFor(PayablesReceivablesView.receivables),
        selectedAccountIds,
      ),
      _filterByAccounts(
        snapshot.visibleFor(PayablesReceivablesView.paid),
        selectedAccountIds,
      ),
      _filterByAccounts(
        snapshot.visibleFor(PayablesReceivablesView.received),
        selectedAccountIds,
      ),
    );
    final groups = _TransactionGroups.from(visible, view);
    final isMobile = ResponsiveLayout.isMobile(context);

    if (!isMobile) {
      return _DesktopLedgerLayout(
        snapshot: snapshot,
        allVisible: allVisible,
        visible: visible,
        summary: summary,
        groups: groups,
        view: view,
        onViewChanged: onViewChanged,
        onAdd: onAdd,
        onOpen: onOpen,
        onSettle: onSettle,
        onDelete: onDelete,
        availableViews: availableViews,
        selectedAccountIds: selectedAccountIds,
        onAccountToggled: onAccountToggled,
      );
    }

    return CustomScrollView(
      slivers: [
        if (isMobile)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Center(child: FinancoMonthFilterPill()),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _LedgerToggle(view, onViewChanged, availableViews),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _SummaryCard(summary: summary, view: view),
          ),
        ),
        if (groups.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyLedger(onAdd: onAdd),
          )
        else ...[
          for (final section in groups.sections)
            _TransactionSection(
              section: section,
              view: view,
              onOpen: onOpen,
              onSettle: onSettle,
              onDelete: onDelete,
            ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: floatingActionScrollEndPadding(
                hasStackedActions: false,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DesktopLedgerLayout extends StatelessWidget {
  const _DesktopLedgerLayout({
    required this.snapshot,
    required this.allVisible,
    required this.visible,
    required this.summary,
    required this.groups,
    required this.view,
    required this.onViewChanged,
    required this.onAdd,
    required this.onOpen,
    required this.onSettle,
    required this.onDelete,
    required this.availableViews,
    required this.selectedAccountIds,
    required this.onAccountToggled,
  });

  final _BillsSnapshot snapshot;
  final List<TransactionEntity> allVisible;
  final List<TransactionEntity> visible;
  final _BillsSummary summary;
  final _TransactionGroups groups;
  final PayablesReceivablesView view;
  final ValueChanged<PayablesReceivablesView> onViewChanged;
  final VoidCallback onAdd;
  final void Function(TransactionEntity) onOpen;
  final void Function(TransactionEntity) onSettle;
  final void Function(TransactionEntity) onDelete;
  final List<PayablesReceivablesView> availableViews;
  final Set<String> selectedAccountIds;
  final void Function(String accountId, List<String> availableAccountIds)
  onAccountToggled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const FinancoMonthFilterPill(),
                  const SizedBox(height: 16),
                  _SummaryCard(summary: summary, view: view),
                  const SizedBox(height: 16),
                  _AccountsTotalsCard(
                    transactions: allVisible,
                    view: view,
                    selectedAccountIds: selectedAccountIds,
                    onAccountToggled: onAccountToggled,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  sliver: SliverToBoxAdapter(
                    child: _LedgerToggle(
                      view,
                      onViewChanged,
                      availableViews,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  sliver: SliverToBoxAdapter(
                    child: _LedgerStatusStrip(view: view),
                  ),
                ),
                if (groups.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyLedger(onAdd: onAdd),
                  )
                else ...[
                  for (final section in groups.sections)
                    _TransactionSection(
                      section: section,
                      view: view,
                      onOpen: onOpen,
                      onSettle: onSettle,
                      onDelete: onDelete,
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: floatingActionScrollEndPadding(
                        hasStackedActions: false,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerStatusStrip extends StatelessWidget {
  const _LedgerStatusStrip({required this.view});

  final PayablesReceivablesView view;

  @override
  Widget build(BuildContext context) {
    final isPending =
        view == PayablesReceivablesView.payables ||
        view == PayablesReceivablesView.receivables;
    return Row(
      children: [
        Text(
          t.general.filter,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        if (isPending) ...[
          _LegendChip(label: t.bills.pending, color: context.appColors.expense),
          const SizedBox(width: 8),
          _LegendChip(
            label: t.bills.scheduled,
            color: context.appColors.warning,
          ),
        ] else ...[
          _LegendChip(
            label: t.bills.confirmed,
            color: context.appColors.income,
          ),
          const SizedBox(width: 8),
          _LegendChip(
            label: t.bills.reconciled,
            color: context.appColors.primary,
          ),
        ],
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountsTotalsCard extends StatelessWidget {
  const _AccountsTotalsCard({
    required this.transactions,
    required this.view,
    required this.selectedAccountIds,
    required this.onAccountToggled,
  });

  final List<TransactionEntity> transactions;
  final PayablesReceivablesView view;
  final Set<String> selectedAccountIds;
  final void Function(String accountId, List<String> availableAccountIds)
  onAccountToggled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accounts = context.watch<AccountsCubit>().state.accountsOrEmpty;
    final accountIds = accounts.map((account) => account.id).toList();
    final rows = accounts
        .map(
          (account) => _AccountTotalRowData(
            account: account,
            amount: _sumForAccount(account.id),
            isSelected: _isSelected(account.id),
          ),
        )
        .toList();
    final total = rows
        .where((row) => row.isSelected)
        .fold<double>(0, (sum, row) => sum + row.amount);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.profile.accounts,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _viewTotalLabel(view),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onBackgroundLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Text(
                t.general.noResults,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onBackgroundLight,
                ),
              )
            else ...[
              for (final row in rows)
                _AccountTotalRow(
                  row: row,
                  view: view,
                  onTap: () => onAccountToggled(row.account!.id, accountIds),
                ),
              const Divider(height: 20),
              _AccountTotalRow(
                row: _AccountTotalRowData(
                  account: null,
                  amount: total,
                  isSelected: true,
                  fallbackName: t.dashboard.total,
                ),
                view: view,
                isTotal: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _sumForAccount(String accountId) => transactions
      .where((tx) => tx.accountId == accountId)
      .fold<double>(0, (sum, tx) => sum + tx.amount);

  bool _isSelected(String accountId) {
    return selectedAccountIds.isEmpty || selectedAccountIds.contains(accountId);
  }
}

class _AccountTotalRowData {
  const _AccountTotalRowData({
    required this.account,
    required this.amount,
    required this.isSelected,
    this.fallbackName,
  });

  final AccountEntity? account;
  final double amount;
  final bool isSelected;
  final String? fallbackName;

  String get name => account?.name ?? fallbackName ?? '';
}

class _AccountTotalRow extends StatelessWidget {
  const _AccountTotalRow({
    required this.row,
    required this.view,
    this.isTotal = false,
    this.onTap,
  });

  final _AccountTotalRowData row;
  final PayablesReceivablesView view;
  final bool isTotal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = _amountColor(context, view);
    final content = Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 3 : 2),
      child: Row(
        children: [
          if (!isTotal) ...[
            Checkbox(
              value: row.isSelected,
              onChanged: (_) => onTap?.call(),
              activeColor: colors.primary,
              checkColor: Colors.white,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            _BankAvatar(account: row.account),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: row.isSelected || isTotal
                    ? colors.onBackground
                    : colors.onBackgroundLight,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _signedAmount(row.amount, view),
            style: context.textTheme.bodySmall?.copyWith(
              color: row.isSelected || isTotal
                  ? color
                  : colors.onBackgroundLight.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (isTotal) return content;

    return Material(
      color: row.isSelected
          ? colors.surfaceVariant.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: content,
      ),
    );
  }
}

class _BankAvatar extends StatelessWidget {
  const _BankAvatar({required this.account});

  final AccountEntity? account;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final account = this.account;
    if (account == null) return const SizedBox.shrink();

    final brand = BankBrand.of(account.bank);
    final background = Color(brand.color);
    final abbreviation = brand.abbreviation.isEmpty
        ? (account.name.isEmpty
              ? '?'
              : account.name.substring(0, 1).toUpperCase())
        : brand.abbreviation;
    return Padding(
      padding: const EdgeInsets.only(right: 1),
      child: Tooltip(
        message: account.bankLabel,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            abbreviation,
            style: context.textTheme.bodySmall?.copyWith(
              color: _readableTextColor(background, colors),
              fontWeight: FontWeight.w700,
              fontSize: abbreviation.length > 2 ? 8 : 9,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

String _viewTotalLabel(PayablesReceivablesView view) => switch (view) {
  PayablesReceivablesView.payables => t.bills.typePayable,
  PayablesReceivablesView.receivables => t.bills.typeReceivable,
  PayablesReceivablesView.paid => t.bills.paidPlural,
  PayablesReceivablesView.received => t.bills.receivedPlural,
};

Color _amountColor(BuildContext context, PayablesReceivablesView view) {
  return switch (view) {
    PayablesReceivablesView.payables ||
    PayablesReceivablesView.paid => context.appColors.expense,
    PayablesReceivablesView.receivables ||
    PayablesReceivablesView.received => context.appColors.income,
  };
}

String _signedAmount(double amount, PayablesReceivablesView view) {
  if (amount == 0) return formatCurrency(0);
  final prefix = switch (view) {
    PayablesReceivablesView.payables || PayablesReceivablesView.paid => '-',
    PayablesReceivablesView.receivables ||
    PayablesReceivablesView.received => '+',
  };
  return '$prefix${formatCurrency(amount)}';
}

List<TransactionEntity> _filterByAccounts(
  List<TransactionEntity> transactions,
  Set<String> selectedAccountIds,
) {
  if (selectedAccountIds.isEmpty) return transactions;
  return transactions
      .where(
        (transaction) => selectedAccountIds.contains(transaction.accountId),
      )
      .toList();
}

Color _readableTextColor(Color background, AppColorsData colors) {
  return background.computeLuminance() > 0.55
      ? colors.background
      : Colors.white;
}

class _LedgerToggle extends StatelessWidget {
  const _LedgerToggle(this.view, this.onChanged, this.availableViews);

  final PayablesReceivablesView view;
  final ValueChanged<PayablesReceivablesView> onChanged;
  final List<PayablesReceivablesView> availableViews;

  @override
  Widget build(BuildContext context) {
    return FinancoPillToggle<PayablesReceivablesView>(
      selected: view,
      onChanged: onChanged,
      options: _allOptions
          .where((option) => availableViews.contains(option.value))
          .toList(),
    );
  }

  List<FinancoPillToggleOption<PayablesReceivablesView>> get _allOptions {
    return [
      FinancoPillToggleOption(
        value: PayablesReceivablesView.payables,
        label: t.bills.typePayable,
        icon: FontAwesomeIcons.arrowUp,
      ),
      FinancoPillToggleOption(
        value: PayablesReceivablesView.receivables,
        label: t.bills.typeReceivable,
        icon: FontAwesomeIcons.arrowDown,
      ),
      FinancoPillToggleOption(
        value: PayablesReceivablesView.paid,
        label: t.bills.paidPlural,
        icon: FontAwesomeIcons.circleCheck,
      ),
      FinancoPillToggleOption(
        value: PayablesReceivablesView.received,
        label: t.bills.receivedPlural,
        icon: FontAwesomeIcons.handHoldingDollar,
      ),
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.view});

  final _BillsSummary summary;
  final PayablesReceivablesView view;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                label: _isSettledModeForView(view)
                    ? t.bills.paid
                    : t.bills.typePayable,
                value: _isSettledModeForView(view)
                    ? summary.paid
                    : summary.toPay,
                color: colors.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryMetric(
                label: _isSettledModeForView(view)
                    ? t.bills.received
                    : t.bills.typeReceivable,
                value: _isSettledModeForView(view)
                    ? summary.received
                    : summary.toReceive,
                color: colors.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatCurrency(value),
            style: context.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionSection extends StatelessWidget {
  const _TransactionSection({
    required this.section,
    required this.view,
    required this.onOpen,
    required this.onSettle,
    required this.onDelete,
  });

  final _TransactionSectionData section;
  final PayablesReceivablesView view;
  final void Function(TransactionEntity) onOpen;
  final void Function(TransactionEntity) onSettle;
  final void Function(TransactionEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          FinancoSectionHeader(
            title: section.title,
            count: section.transactions.length,
            accent: section.color(context),
          ),
          ...section.transactions.map(
            (transaction) => _DismissibleTransactionTile(
              transaction: transaction,
              view: view,
              onOpen: () => onOpen(transaction),
              onSettle: () => onSettle(transaction),
              onDelete: () => onDelete(transaction),
            ),
          ),
        ]),
      ),
    );
  }
}

class _DismissibleTransactionTile extends StatelessWidget {
  const _DismissibleTransactionTile({
    required this.transaction,
    required this.view,
    required this.onOpen,
    required this.onSettle,
    required this.onDelete,
  });

  final TransactionEntity transaction;
  final PayablesReceivablesView view;
  final VoidCallback onOpen;
  final VoidCallback onSettle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: context.appColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const FaIcon(FontAwesomeIcons.trash, color: Colors.white),
      ),
      child: _TransactionTile(
        transaction: transaction,
        view: view,
        onOpen: onOpen,
        onSettle: onSettle,
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.view,
    required this.onOpen,
    required this.onSettle,
  });

  final TransactionEntity transaction;
  final PayablesReceivablesView view;
  final VoidCallback onOpen;
  final VoidCallback onSettle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = transaction.isReceivable ? colors.income : colors.expense;
    final category = _categoryLabel(context, transaction.categoryId);
    final isPendingView =
        view == PayablesReceivablesView.payables ||
        view == PayablesReceivablesView.receivables;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatusDisc(transaction: transaction, color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description.isEmpty
                            ? t.transactions.transaction
                            : transaction.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(transaction, category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: transaction.isOverdue
                              ? colors.expense
                              : colors.onBackgroundLight,
                          fontWeight: transaction.isOverdue
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _Amount(transaction: transaction),
                if (isPendingView) ...[
                  const SizedBox(width: 8),
                  _SettleButton(
                    transaction: transaction,
                    color: accent,
                    onPressed: onSettle,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle(TransactionEntity transaction, String? category) {
    final parts = <String>[
      formatDayMonth(
        transaction.isPending ? transaction.dueDate : transaction.date,
      ),
    ];
    if (category != null && category.isNotEmpty) parts.add(category);
    if (transaction.isPending) {
      if (transaction.isOverdue) {
        parts.add(t.bills.overdue);
      } else if (transaction.isDueToday) {
        parts.add(t.bills.dueToday);
      } else {
        parts.add(t.bills.scheduled);
      }
    } else {
      parts.add(transaction.isReceivable ? t.bills.received : t.bills.paid);
    }
    return parts.join(' · ');
  }

  String? _categoryLabel(BuildContext context, String categoryId) {
    if (categoryId.isEmpty) return null;
    final categories = context.read<CategoriesCubit>().state.categoriesOrEmpty;
    final category = categories.where((c) => c.id == categoryId).firstOrNull;
    return category?.displayPath(categories);
  }
}

class _StatusDisc extends StatelessWidget {
  const _StatusDisc({required this.transaction, required this.color});

  final TransactionEntity transaction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = transaction.isPaid
        ? FontAwesomeIcons.circleCheck
        : transaction.isOverdue
        ? FontAwesomeIcons.triangleExclamation
        : FontAwesomeIcons.clock;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: FaIcon(icon, size: 17, color: color)),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isReceivable
        ? context.appColors.income
        : context.appColors.expense;
    final prefix = transaction.isReceivable ? '+' : '-';
    return Text(
      '$prefix${formatCurrency(transaction.amount)}',
      style: context.textTheme.titleSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SettleButton extends StatelessWidget {
  const _SettleButton({
    required this.transaction,
    required this.color,
    required this.onPressed,
  });

  final TransactionEntity transaction;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: transaction.isReceivable
          ? t.bills.markAsReceived
          : t.bills.markAsPaid,
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: FaIcon(FontAwesomeIcons.check, size: 14, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyLedger extends StatelessWidget {
  const _EmptyLedger({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.surfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.calendarCheck,
                        size: 24,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.bills.emptyTitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.bills.empty,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackgroundLight,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: Text(t.transactions.addTransaction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BillsSnapshot {
  const _BillsSnapshot({
    required this.month,
    required this.transactions,
  });

  final DateTime month;
  final List<TransactionEntity> transactions;

  List<TransactionEntity> visibleFor(PayablesReceivablesView view) {
    final start = startOfMonth(month);
    final end = endOfMonth(month);
    final visible = transactions.where((tx) {
      return switch (view) {
        PayablesReceivablesView.payables =>
          tx.isPending && tx.isPayable && !tx.dueDate.isAfter(end),
        PayablesReceivablesView.receivables =>
          tx.isPending && tx.isReceivable && !tx.dueDate.isAfter(end),
        PayablesReceivablesView.paid =>
          tx.isPaid && tx.isPayable && _inRange(tx.date, start, end),
        PayablesReceivablesView.received =>
          tx.isPaid && tx.isReceivable && _inRange(tx.date, start, end),
      };
    }).toList();

    return visible..sort((a, b) {
      final dateA = a.isPending ? a.dueDate : a.date;
      final dateB = b.isPending ? b.dueDate : b.date;
      return a.isPending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }
}

class _BillsSummary {
  const _BillsSummary({
    required this.toPay,
    required this.toReceive,
    required this.paid,
    required this.received,
  });

  factory _BillsSummary.from(
    List<TransactionEntity> payables,
    List<TransactionEntity> receivables,
    List<TransactionEntity> paid,
    List<TransactionEntity> received,
  ) {
    return _BillsSummary(
      toPay: payables.fold<double>(0, (sum, tx) => sum + tx.amount),
      toReceive: receivables.fold<double>(0, (sum, tx) => sum + tx.amount),
      paid: paid.fold<double>(0, (sum, tx) => sum + tx.amount),
      received: received.fold<double>(0, (sum, tx) => sum + tx.amount),
    );
  }

  final double toPay;
  final double toReceive;
  final double paid;
  final double received;
}

class _TransactionGroups {
  const _TransactionGroups(this.sections);

  factory _TransactionGroups.from(
    List<TransactionEntity> transactions,
    PayablesReceivablesView view,
  ) {
    if (view == PayablesReceivablesView.paid ||
        view == PayablesReceivablesView.received) {
      return _TransactionGroups(
        [
          _TransactionSectionData(
            title: view == PayablesReceivablesView.paid
                ? t.bills.paidPlural
                : t.bills.receivedPlural,
            transactions: transactions,
            color: (context) => context.appColors.onBackgroundLight,
          ),
        ].where((section) => section.transactions.isNotEmpty).toList(),
      );
    }

    final overdue = <TransactionEntity>[];
    final today = <TransactionEntity>[];
    final upcoming = <TransactionEntity>[];
    for (final tx in transactions) {
      if (tx.isOverdue) {
        overdue.add(tx);
      } else if (tx.isDueToday) {
        today.add(tx);
      } else {
        upcoming.add(tx);
      }
    }

    return _TransactionGroups(
      [
        _TransactionSectionData(
          title: t.bills.overdueGroup,
          transactions: overdue,
          color: (context) => context.appColors.expense,
        ),
        _TransactionSectionData(
          title: t.bills.todayGroup,
          transactions: today,
          color: (context) => context.appColors.warning,
        ),
        _TransactionSectionData(
          title: t.bills.upcomingGroup,
          transactions: upcoming,
          color: (context) => context.appColors.primary,
        ),
      ].where((section) => section.transactions.isNotEmpty).toList(),
    );
  }

  final List<_TransactionSectionData> sections;

  bool get isEmpty => sections.isEmpty;
}

class _TransactionSectionData {
  const _TransactionSectionData({
    required this.title,
    required this.transactions,
    required this.color,
  });

  final String title;
  final List<TransactionEntity> transactions;
  final Color Function(BuildContext context) color;
}

class _SnapshotLoadException implements Exception {
  const _SnapshotLoadException(this.failure);

  final Failure failure;
}

bool _inRange(DateTime date, DateTime start, DateTime end) =>
    !date.isBefore(start) && !date.isAfter(end);

bool _isSettledMode(List<PayablesReceivablesView> views) {
  return views.every(_isSettledModeForView);
}

bool _isSettledModeForView(PayablesReceivablesView view) {
  return view == PayablesReceivablesView.paid ||
      view == PayablesReceivablesView.received;
}
