import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_section_header.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/bills/presentation/widgets/bill_status_dot.dart';
import 'package:financo/features/bills/presentation/widgets/bill_tile.dart';
import 'package:financo/features/bills/presentation/widgets/bills_empty_state.dart';
import 'package:financo/features/bills/presentation/widgets/bills_summary_card.dart';
import 'package:financo/features/bills/presentation/widgets/bills_type_pills.dart';
import 'package:financo/features/bills/presentation/widgets/pay_bill_dialog.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:financo/features/dashboard/presentation/bloc/dashboard_event_state.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  BillsTypeFilter _typeFilter = BillsTypeFilter.all;

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.microtask(() {
        if (mounted) {
          context.read<BillsBloc>().add(const BillsLoadRequested());
        }
      }),
    );
  }

  Future<void> _confirmDelete(BillEntity bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.general.delete),
        content: Text(t.bills.deleteConfirm),
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

    if (confirmed == true && mounted) {
      context.read<BillsBloc>().add(BillDeleteRequested(bill.id));
    }
  }

  Future<void> _onPayPressed(BillEntity bill) async {
    await showPayBillDialog(context: context, bill: bill);
  }

  Future<void> _openAddBill() async {
    final result = await context.push(AppRoutes.addBill);
    if (result == true && mounted) {
      context.read<BillsBloc>().add(
        const BillsLoadRequested(forceRefresh: true),
      );
    }
  }

  Future<void> _onTapBill(BillEntity bill) async {
    final result = await context.push<bool>(AppRoutes.editBill, extra: bill);
    if (result == true && mounted) {
      context.read<BillsBloc>().add(
        const BillsLoadRequested(forceRefresh: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillsBloc, BillsState>(
      listener: _onBillsStateChanged,
      child: Scaffold(
        appBar: FinancoLargeAppBar(title: t.bills.title),
        floatingActionButton: LiftedFab(
          child: FloatingActionButton(
            heroTag: 'bills_fab',
            onPressed: _openAddBill,
            child: const Icon(Icons.add),
          ),
        ),
        body: BlocBuilder<BillsBloc, BillsState>(
          builder: (context, state) {
            if (state is BillsLoading || state is BillsInitial) {
              return const LoadingShimmer();
            }
            if (state is BillsError) {
              return ErrorView(
                message: state.failure.message,
                onRetry: () => context.read<BillsBloc>().add(
                  const BillsLoadRequested(forceRefresh: true),
                ),
              );
            }
            if (state is BillsLoaded) {
              return _BillsContent(
                bills: state.bills,
                typeFilter: _typeFilter,
                onFilterChanged: (f) => setState(() => _typeFilter = f),
                onTapBill: _onTapBill,
                onPayBill: _onPayPressed,
                onDeleteBill: _confirmDelete,
                onAddBill: _openAddBill,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _onBillsStateChanged(BuildContext context, BillsState state) {
    if (state is BillsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.failure.message)),
      );
    }
    if (state is BillPaid) {
      // Refresh transactions + dashboard so the new tx shows up immediately,
      // since paying a bill creates a real transaction in another collection.
      context.read<TransactionsBloc>().add(
        TransactionsLoadRequested(forceRefresh: true),
      );
      context.read<DashboardBloc>().add(
        const DashboardRefreshRequested(),
      );
      final messenger = ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.result.paidBill.isReceivable
                  ? t.bills.billReceived
                  : t.bills.billPaid,
            ),
          ),
        );
      if (state.result.nextOccurrence != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.bills.nextOccurrenceCreated)),
        );
      }
    }
  }
}

/// The body shown once bills have loaded. Splits filtering, summary, and
/// list rendering away from the page-level state machine for clarity.
class _BillsContent extends StatelessWidget {
  const _BillsContent({
    required this.bills,
    required this.typeFilter,
    required this.onFilterChanged,
    required this.onTapBill,
    required this.onPayBill,
    required this.onDeleteBill,
    required this.onAddBill,
  });

  final List<BillEntity> bills;
  final BillsTypeFilter typeFilter;
  final ValueChanged<BillsTypeFilter> onFilterChanged;
  final void Function(BillEntity) onTapBill;
  final void Function(BillEntity) onPayBill;
  final void Function(BillEntity) onDeleteBill;
  final VoidCallback onAddBill;

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return BillsEmptyState(onAddPressed: onAddBill);
    }

    final filtered = _applyTypeFilter(bills, typeFilter);
    final summary = BillsSummary.from(filtered);
    final groups = _BillGroups.fromBills(filtered);

    return CustomScrollView(
      slivers: [
        if (!summary.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: BillsSummaryCard(summary: summary),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(0, summary.isEmpty ? 16 : 8, 0, 8),
          sliver: SliverToBoxAdapter(
            child: BillsTypePills(
              selected: typeFilter,
              onChanged: onFilterChanged,
              labels: (
                all: t.bills.filterAll,
                payable: t.bills.typePayable,
                receivable: t.bills.typeReceivable,
              ),
            ),
          ),
        ),
        if (groups.isFullyEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _NoMatchingFilter(),
          )
        else ...[
          if (groups.overdue.isNotEmpty)
            _BillsSliverSection(
              title: t.bills.overdueGroup,
              accent: context.appColors.expense,
              bills: groups.overdue,
              onTap: onTapBill,
              onPay: onPayBill,
              onDelete: onDeleteBill,
            ),
          if (groups.today.isNotEmpty)
            _BillsSliverSection(
              title: t.bills.todayGroup,
              accent: context.appColors.warning,
              bills: groups.today,
              onTap: onTapBill,
              onPay: onPayBill,
              onDelete: onDeleteBill,
            ),
          if (groups.upcoming.isNotEmpty)
            _BillsSliverSection(
              title: t.bills.upcomingGroup,
              accent: context.appColors.primary,
              bills: groups.upcoming,
              onTap: onTapBill,
              onPay: onPayBill,
              onDelete: onDeleteBill,
            ),
          if (groups.paid.isNotEmpty)
            _BillsSliverSection(
              title: t.bills.paidGroup,
              accent: context.appColors.onBackgroundLight,
              bills: groups.paid,
              onTap: onTapBill,
              onPay: onPayBill,
              onDelete: onDeleteBill,
            ),
          // Bottom breathing room so the FAB doesn't crop the last tile.
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ],
    );
  }

  List<BillEntity> _applyTypeFilter(
    List<BillEntity> all,
    BillsTypeFilter filter,
  ) {
    return switch (filter) {
      BillsTypeFilter.all => all,
      BillsTypeFilter.payable =>
        all.where((b) => b.type == BillType.payable).toList(),
      BillsTypeFilter.receivable =>
        all.where((b) => b.type == BillType.receivable).toList(),
    };
  }
}

class _BillGroups {
  const _BillGroups({
    required this.overdue,
    required this.today,
    required this.upcoming,
    required this.paid,
  });

  factory _BillGroups.fromBills(List<BillEntity> bills) {
    final overdue = <BillEntity>[];
    final today = <BillEntity>[];
    final upcoming = <BillEntity>[];
    final paid = <BillEntity>[];

    for (final b in bills) {
      switch (b.statusKind) {
        case BillStatusKind.overdue:
          overdue.add(b);
        case BillStatusKind.today:
          today.add(b);
        case BillStatusKind.upcoming:
          upcoming.add(b);
        case BillStatusKind.paid:
          paid.add(b);
      }
    }

    paid.sort(
      (a, b) => (b.paidAt ?? b.updatedAt).compareTo(a.paidAt ?? a.updatedAt),
    );

    return _BillGroups(
      overdue: overdue,
      today: today,
      upcoming: upcoming,
      paid: paid,
    );
  }

  final List<BillEntity> overdue;
  final List<BillEntity> today;
  final List<BillEntity> upcoming;
  final List<BillEntity> paid;

  bool get isFullyEmpty =>
      overdue.isEmpty && today.isEmpty && upcoming.isEmpty && paid.isEmpty;
}

class _BillsSliverSection extends StatelessWidget {
  const _BillsSliverSection({
    required this.title,
    required this.accent,
    required this.bills,
    required this.onTap,
    required this.onPay,
    required this.onDelete,
  });

  final String title;
  final Color accent;
  final List<BillEntity> bills;
  final void Function(BillEntity) onTap;
  final void Function(BillEntity) onPay;
  final void Function(BillEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          FinancoSectionHeader(
            title: title,
            count: bills.length,
            accent: accent,
          ),
          ...bills.map(
            (bill) => Dismissible(
              key: ValueKey(bill.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                onDelete(bill);
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
                child: const FaIcon(
                  FontAwesomeIcons.trash,
                  color: Colors.white,
                ),
              ),
              child: BillTile(
                bill: bill,
                onTap: () => onTap(bill),
                onPayPressed: () => onPay(bill),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _NoMatchingFilter extends StatelessWidget {
  const _NoMatchingFilter();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          t.general.noResults,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}
