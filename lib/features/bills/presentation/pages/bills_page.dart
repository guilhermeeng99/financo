import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/empty_state.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:financo/features/bills/presentation/bloc/bills_event_state.dart';
import 'package:financo/features/bills/presentation/widgets/bill_tile.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillsBloc, BillsState>(
      listener: (context, state) {
        if (state is BillsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
          );
        }
        if (state is BillPaid) {
          // Refresh transactions + dashboard so the new expense shows up.
          context.read<TransactionsBloc>().add(
            TransactionsLoadRequested(forceRefresh: true),
          );
          context.read<DashboardBloc>().add(
            const DashboardRefreshRequested(),
          );
          final messenger = ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(t.bills.billPaid)));
          if (state.result.nextOccurrence != null) {
            messenger.showSnackBar(
              SnackBar(content: Text(t.bills.nextOccurrenceCreated)),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(t.bills.title)),
        floatingActionButton: FloatingActionButton(
          heroTag: 'bills_fab',
          onPressed: () async {
            final result = await context.push(AppRoutes.addBill);
            if (result == true && context.mounted) {
              context.read<BillsBloc>().add(
                const BillsLoadRequested(forceRefresh: true),
              );
            }
          },
          child: const Icon(Icons.add),
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
              if (state.bills.isEmpty) {
                return EmptyState(
                  icon: FontAwesomeIcons.fileInvoiceDollar,
                  message: t.bills.empty,
                );
              }
              return _BillsList(
                bills: state.bills,
                onTap: _onTapBill,
                onPay: _onPayPressed,
                onDelete: _confirmDelete,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _onTapBill(BillEntity bill) async {
    final result = await context.push<bool>(AppRoutes.editBill, extra: bill);
    if (result == true && mounted) {
      context.read<BillsBloc>().add(
        const BillsLoadRequested(forceRefresh: true),
      );
    }
  }
}

class _BillsList extends StatelessWidget {
  const _BillsList({
    required this.bills,
    required this.onTap,
    required this.onPay,
    required this.onDelete,
  });

  final List<BillEntity> bills;
  final void Function(BillEntity) onTap;
  final void Function(BillEntity) onPay;
  final void Function(BillEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    final overdue = bills.where((b) => b.isOverdue).toList();
    final today = bills.where((b) => b.isDueToday).toList();
    final upcoming = bills
        .where((b) => b.isPending && !b.isOverdue && !b.isDueToday)
        .toList();
    final paid = bills.where((b) => b.isPaid).toList()
      ..sort((a, b) => (b.paidAt ?? b.updatedAt)
          .compareTo(a.paidAt ?? a.updatedAt));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overdue.isNotEmpty)
          _Section(
            title: t.bills.overdueGroup,
            bills: overdue,
            onTap: onTap,
            onPay: onPay,
            onDelete: onDelete,
          ),
        if (today.isNotEmpty)
          _Section(
            title: t.bills.todayGroup,
            bills: today,
            onTap: onTap,
            onPay: onPay,
            onDelete: onDelete,
          ),
        if (upcoming.isNotEmpty)
          _Section(
            title: t.bills.upcomingGroup,
            bills: upcoming,
            onTap: onTap,
            onPay: onPay,
            onDelete: onDelete,
          ),
        if (paid.isNotEmpty)
          _Section(
            title: t.bills.paidGroup,
            bills: paid,
            onTap: onTap,
            onPay: onPay,
            onDelete: onDelete,
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.bills,
    required this.onTap,
    required this.onPay,
    required this.onDelete,
  });

  final String title;
  final List<BillEntity> bills;
  final void Function(BillEntity) onTap;
  final void Function(BillEntity) onPay;
  final void Function(BillEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 12, bottom: 4),
          child: Text(
            title,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.appColors.onBackgroundLight,
              fontWeight: FontWeight.w600,
            ),
          ),
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
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              color: context.appColors.expense,
              child: const FaIcon(FontAwesomeIcons.trash, color: Colors.white),
            ),
            child: BillTile(
              bill: bill,
              onTap: () => onTap(bill),
              onPayPressed: () => onPay(bill),
            ),
          ),
        ),
      ],
    );
  }
}
