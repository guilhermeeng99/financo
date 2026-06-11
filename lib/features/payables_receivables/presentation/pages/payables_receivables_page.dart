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

part 'payables_receivables_accounts_panel.dart';
part 'payables_receivables_ledger_widgets.dart';
part 'payables_receivables_models.dart';

enum PayablesReceivablesView { payables, receivables, paid, received }

class PayablesReceivablesPage extends StatefulWidget {
  const PayablesReceivablesPage({
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
  State<PayablesReceivablesPage> createState() =>
      _PayablesReceivablesPageState();
}

class _PayablesReceivablesPageState extends State<PayablesReceivablesPage> {
  late PayablesReceivablesView _view;
  Future<_PayablesReceivablesSnapshot>? _future;
  Set<String>? _selectedAccountIds;

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
  void didUpdateWidget(covariant PayablesReceivablesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialView != widget.initialView) {
      _view = widget.initialView;
    }
  }

  Future<_PayablesReceivablesSnapshot> _load({
    bool forceRefresh = false,
  }) async {
    final filter = context.read<DateFilterCubit>().state;
    final month = DateTime(filter.year, filter.month);
    final result = await GetIt.I<GetTransactionsUseCase>()(
      userId: _userId,
      endDate: endOfMonth(month),
      forceRefresh: forceRefresh,
    );
    return result.fold(
      (failure) => throw _SnapshotLoadException(failure),
      (transactions) => _PayablesReceivablesSnapshot(
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
      final selected = _selectedAccountIds == null
          ? available
          : _selectedAccountIds!.where(available.contains).toSet();
      if (selected.contains(accountId)) {
        selected.remove(accountId);
      } else {
        selected.add(accountId);
      }
      _selectedAccountIds = selected;
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
                  ? t.payablesReceivables.transactionReceived
                  : t.payablesReceivables.transactionPaid,
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
            heroTag: widget.embedded
                ? 'embedded_payables_receivables_fab'
                : 'payables_receivables_fab',
            onPressed: _openAddTransaction,
            child: const Icon(Icons.add),
          ),
        ),
        body: FutureBuilder<_PayablesReceivablesSnapshot>(
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
            return _PayablesReceivablesContent(
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

class _PayablesReceivablesContent extends StatelessWidget {
  const _PayablesReceivablesContent({
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

  final _PayablesReceivablesSnapshot snapshot;
  final PayablesReceivablesView view;
  final ValueChanged<PayablesReceivablesView> onViewChanged;
  final VoidCallback onAdd;
  final void Function(TransactionEntity) onOpen;
  final void Function(TransactionEntity) onSettle;
  final void Function(TransactionEntity) onDelete;
  final bool embedded;
  final List<PayablesReceivablesView> availableViews;
  final Set<String>? selectedAccountIds;
  final void Function(String accountId, List<String> availableAccountIds)
  onAccountToggled;

  @override
  Widget build(BuildContext context) {
    final visibleAccountIds = context
        .watch<AccountsCubit>()
        .state
        .accountsOrEmpty
        .where((account) => account.type != AccountType.investment)
        .map((account) => account.id)
        .toSet();
    final effectiveSelectedAccountIds = selectedAccountIds == null
        ? visibleAccountIds
        : selectedAccountIds!.intersection(visibleAccountIds);
    final allVisible = _filterByAvailableAccounts(
      snapshot.visibleFor(view),
      visibleAccountIds,
    );
    final visible = _filterByAccounts(allVisible, effectiveSelectedAccountIds);
    final summary = _PayablesReceivablesSummary.from(
      _filterByAccounts(
        _filterByAvailableAccounts(
          snapshot.visibleFor(PayablesReceivablesView.payables),
          visibleAccountIds,
        ),
        effectiveSelectedAccountIds,
      ),
      _filterByAccounts(
        _filterByAvailableAccounts(
          snapshot.visibleFor(PayablesReceivablesView.receivables),
          visibleAccountIds,
        ),
        effectiveSelectedAccountIds,
      ),
      _filterByAccounts(
        _filterByAvailableAccounts(
          snapshot.visibleFor(PayablesReceivablesView.paid),
          visibleAccountIds,
        ),
        effectiveSelectedAccountIds,
      ),
      _filterByAccounts(
        _filterByAvailableAccounts(
          snapshot.visibleFor(PayablesReceivablesView.received),
          visibleAccountIds,
        ),
        effectiveSelectedAccountIds,
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
        selectedAccountIds: effectiveSelectedAccountIds,
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

  final _PayablesReceivablesSnapshot snapshot;
  final List<TransactionEntity> allVisible;
  final List<TransactionEntity> visible;
  final _PayablesReceivablesSummary summary;
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
