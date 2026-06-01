import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/financo_month_filter_pill.dart';
import 'package:financo/app/widgets/financo_section_header.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/responsive_layout.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/entities/bill_match_candidate.dart';
import 'package:financo/features/bills/presentation/bills_view.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/bills/presentation/widgets/bill_match_banner.dart';
import 'package:financo/features/bills/presentation/widgets/bill_match_sheet.dart';
import 'package:financo/features/bills/presentation/widgets/bill_tile.dart';
import 'package:financo/features/bills/presentation/widgets/bills_csv_import_dialog.dart';
import 'package:financo/features/bills/presentation/widgets/bills_empty_state.dart';
import 'package:financo/features/bills/presentation/widgets/bills_summary_card.dart';
import 'package:financo/features/bills/presentation/widgets/bills_type_pills.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
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
  const BillsPage({super.key, this.embedded = false});

  /// When `true`, the page is mounted as a sub-tab and skips its own
  /// `FinancoLargeAppBar` — the parent shell hosts the title row. The
  /// CSV-import affordance moves to a small secondary FAB stacked
  /// above the primary "+" so users can still kick off an import.
  final bool embedded;

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
          final filter = context.read<DateFilterCubit>().state;
          context.read<BillsBloc>().add(
            BillsLoadRequested(year: filter.year, month: filter.month),
          );
        }
      }),
    );
  }

  Future<void> _confirmDelete(BillEntity bill) async {
    final confirmed = await showFinancoConfirmDialog(
      context,
      icon: FontAwesomeIcons.trashCan,
      title: t.general.delete,
      message: t.bills.deleteConfirm,
      confirmLabel: t.general.delete,
      destructive: true,
    );

    if (confirmed && mounted) {
      context.read<BillsBloc>().add(BillDeleteRequested(bill.id));
    }
  }

  Future<void> _onPayPressed(BillEntity bill) async {
    // Settling a bill goes through the regular transaction-create form
    // with prefilled fields. Once the user saves, the form auto-links
    // the new tx to this bill via `BillMatchAccepted` (see
    // AddTransactionPage._onFormStateChanged).
    await context.push(AppRoutes.addTransaction, extra: bill);
  }

  Future<void> _openAddBill() async {
    final result = await context.push(AppRoutes.addBill);
    if (result == true && mounted) {
      context.read<BillsBloc>().add(
        const BillsLoadRequested(forceRefresh: true),
      );
    }
  }

  Future<void> _openImport() => showBillsCsvImportDialog(context);

  Future<void> _onTapBill(BillEntity bill) async {
    if (bill.isVirtual) {
      // Virtual previews can't be edited (no Firestore doc to update).
      // Guide the user toward the unblocking action — settle the prior
      // real occurrence — instead of opening a half-broken form.
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(t.bills.virtualBlocked)),
        );
      return;
    }
    final result = await context.push<bool>(AppRoutes.editBill, extra: bill);
    if (result == true && mounted) {
      context.read<BillsBloc>().add(
        const BillsLoadRequested(forceRefresh: true),
      );
    }
  }

  Future<void> _openMatchSheet(List<BillMatchCandidate> candidates) async {
    final bloc = context.read<BillsBloc>();
    // Resolver built once at sheet-open time. Reading the cubit inside
    // the sheet's builder would also work, but capturing it here keeps
    // BillMatchSheet free of CategoriesCubit imports.
    final categories = context.read<CategoriesCubit>().state.categoriesOrEmpty;
    final categoryMap = {for (final c in categories) c.id: c};
    String? categoryLabelFor(String? id) {
      if (id == null || id.isEmpty) return null;
      return categoryMap[id]?.displayPath(categoryMap.values);
    }

    await BillMatchSheet.show(
      context: context,
      candidates: candidates,
      categoryLabelFor: categoryLabelFor,
      onAccept: (bill, tx) {
        Navigator.of(context).pop();
        bloc.add(
          BillMatchAccepted(billId: bill.id, transactionId: tx.id),
        );
      },
      onReject: (bill, tx) {
        bloc.add(
          BillMatchRejected(billId: bill.id, transactionId: tx.id),
        );
        // Sheet stays open so the user can keep working through the list.
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(t.bills.match.matchRejected)),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BillsBloc, BillsState>(listener: _onBillsStateChanged),
        // Re-load (and re-project virtuals) every time the user steps the
        // month — DateFilterCubit is the global month selector shared
        // with dashboard/transactions.
        BlocListener<DateFilterCubit, DateFilterState>(
          listener: (context, filter) {
            context.read<BillsBloc>().add(
              BillsLoadRequested(
                year: filter.year,
                month: filter.month,
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: widget.embedded
            ? null
            : FinancoLargeAppBar(
                title: t.bills.title,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 4),
                    child: FinancoAppBarIconButton(
                      icon: FontAwesomeIcons.fileArrowUp,
                      tooltip: t.bills.importCsv,
                      color: context.appColors.primary,
                      onPressed: () => unawaited(_openImport()),
                    ),
                  ),
                ],
              ),
        floatingActionButton: widget.embedded
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'bills_import_fab',
                    onPressed: () => unawaited(_openImport()),
                    tooltip: t.bills.importCsv,
                    child: const FaIcon(
                      FontAwesomeIcons.fileArrowUp,
                      size: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LiftedFab(
                    child: FloatingActionButton(
                      heroTag: 'bills_fab',
                      onPressed: _openAddBill,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              )
            : LiftedFab(
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
                failure: state.failure,
                onRetry: () => context.read<BillsBloc>().add(
                  const BillsLoadRequested(forceRefresh: true),
                ),
              );
            }
            if (state is BillsLoaded) {
              return _BillsContent(
                bills: state.bills,
                virtualBills: state.virtualBills,
                matchCandidates: state.matchCandidates,
                hasStackedFloatingActions: widget.embedded,
                typeFilter: _typeFilter,
                onFilterChanged: (f) => setState(() => _typeFilter = f),
                onTapBill: _onTapBill,
                onPayBill: _onPayPressed,
                onDeleteBill: _confirmDelete,
                onAddBill: _openAddBill,
                onOpenMatchSheet: _openMatchSheet,
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
        SnackBar(content: Text(localizedFailure(state.failure))),
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
    required this.virtualBills,
    required this.matchCandidates,
    required this.hasStackedFloatingActions,
    required this.typeFilter,
    required this.onFilterChanged,
    required this.onTapBill,
    required this.onPayBill,
    required this.onDeleteBill,
    required this.onAddBill,
    required this.onOpenMatchSheet,
  });

  final List<BillEntity> bills;

  /// Projected previews of upcoming monthly occurrences. Virtuals carry
  /// `id == ''` and are merged with `bills` for display purposes only —
  /// summary totals, list grouping, and tile rendering treat them as
  /// regular pending bills (the tile itself dims them and hides pay).
  final List<BillEntity> virtualBills;
  final List<BillMatchCandidate> matchCandidates;
  final bool hasStackedFloatingActions;
  final BillsTypeFilter typeFilter;
  final ValueChanged<BillsTypeFilter> onFilterChanged;
  final void Function(BillEntity) onTapBill;
  final void Function(BillEntity) onPayBill;
  final void Function(BillEntity) onDeleteBill;
  final VoidCallback onAddBill;
  final void Function(List<BillMatchCandidate>) onOpenMatchSheet;

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty && virtualBills.isEmpty) {
      return BillsEmptyState(onAddPressed: onAddBill);
    }

    // Scope to the selected month + carry-over of pending bills from
    // earlier months. See docs/specs/bills.md → "Bills List Display".
    final dateFilter = context.watch<DateFilterCubit>().state;
    final merged = [...bills, ...virtualBills];
    final monthFiltered = filterBillsForMonth(
      merged,
      year: dateFilter.year,
      month: dateFilter.month,
    );

    final categories = context.watch<CategoriesCubit>().state.categoriesOrEmpty;
    final categoryMap = {for (final c in categories) c.id: c};
    String? labelFor(BillEntity bill) {
      final id = bill.categoryId;
      if (id == null || id.isEmpty) return null;
      final category = categoryMap[id];
      return category?.displayPath(categoryMap.values);
    }

    final filtered = filterBillsByType(monthFiltered, typeFilter);
    final summary = BillsSummary.from(filtered);
    final groups = BillGroups.fromBills(filtered);
    // Match candidates only consider real bills (virtuals have no id).
    final visibleCandidates = filterMatchCandidates(
      matchCandidates,
      typeFilter,
      monthFiltered.where((b) => !b.isVirtual).map((b) => b.id).toSet(),
    );

    // The shell renders the sidebar at >=600px and that sidebar already
    // hosts a month stepper. On mobile the sidebar is hidden, so the
    // body has to surface the pill itself — same rule the dashboard uses.
    final isMobile = ResponsiveLayout.isMobile(context);
    final bottomSpacerHeight = floatingActionScrollEndPadding(
      hasStackedActions: isMobile && hasStackedFloatingActions,
    );

    return CustomScrollView(
      slivers: [
        if (isMobile)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Center(child: FinancoMonthFilterPill()),
            ),
          ),
        if (visibleCandidates.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: BillMatchBanner(
                candidateCount: visibleCandidates.length,
                onTap: () => onOpenMatchSheet(visibleCandidates),
              ),
            ),
          ),
        if (!summary.isEmpty)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              visibleCandidates.isEmpty ? 16 : 12,
              16,
              8,
            ),
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
              labelFor: labelFor,
              isPayable: isBillPayable,
            ),
          if (groups.today.isNotEmpty)
            _BillsSliverSection(
              title: t.bills.todayGroup,
              accent: context.appColors.warning,
              bills: groups.today,
              onTap: onTapBill,
              onPay: onPayBill,
              onDelete: onDeleteBill,
              labelFor: labelFor,
              isPayable: isBillPayable,
            ),
          if (groups.upcoming.isNotEmpty)
            _BillsSliverSection(
              title: t.bills.upcomingGroup,
              accent: context.appColors.primary,
              bills: groups.upcoming,
              onTap: onTapBill,
              onPay: onPayBill,
              onDelete: onDeleteBill,
              labelFor: labelFor,
              isPayable: isBillPayable,
            ),
          if (groups.paid.isNotEmpty)
            _BillsSliverSection(
              title: t.bills.paidGroup,
              accent: context.appColors.onBackgroundLight,
              bills: groups.paid,
              onTap: onTapBill,
              onPay: onPayBill,
              onDelete: onDeleteBill,
              labelFor: labelFor,
              isPayable: isBillPayable,
            ),
          // Bottom breathing room so the lifted FAB stack doesn't crop the
          // last tile on mobile.
          SliverToBoxAdapter(child: SizedBox(height: bottomSpacerHeight)),
        ],
      ],
    );
  }
}

class _BillsSliverSection extends StatelessWidget {
  const _BillsSliverSection({
    required this.title,
    required this.accent,
    required this.bills,
    required this.onTap,
    required this.onPay,
    required this.onDelete,
    required this.labelFor,
    required this.isPayable,
  });

  final String title;
  final Color accent;
  final List<BillEntity> bills;
  final void Function(BillEntity) onTap;
  final void Function(BillEntity) onPay;
  final void Function(BillEntity) onDelete;
  final String? Function(BillEntity) labelFor;
  final bool Function(BillEntity) isPayable;

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
          ...bills.map((bill) {
            final tile = BillTile(
              bill: bill,
              categoryLabel: labelFor(bill),
              isPayable: isPayable(bill),
              onTap: () => onTap(bill),
              onPayPressed: () => onPay(bill),
            );
            // Virtuals don't have a Firestore doc to delete — give them
            // a stable key (their projected dueDate) and skip the swipe
            // affordance entirely so the gesture isn't a dead end.
            if (bill.isVirtual) {
              return KeyedSubtree(
                key: ValueKey('virtual-${bill.dueDate.toIso8601String()}'),
                child: tile,
              );
            }
            return Dismissible(
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
              child: tile,
            );
          }),
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
