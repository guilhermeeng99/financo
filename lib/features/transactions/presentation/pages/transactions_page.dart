import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/empty_state.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/transaction_tile.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    final filter = context.read<DateFilterCubit>().state;
    context.read<TransactionsBloc>().add(
      TransactionsLoadRequested(year: filter.year, month: filter.month),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoAppBar(title: t.transactions.title),
      body: BlocListener<TransactionsBloc, TransactionsState>(
        listener: (context, state) {
          if (state is TransactionsImported) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  t.transactions.importSuccess(
                    imported: state.importedCount,
                    skipped: state.skippedCount,
                  ),
                ),
              ),
            );
            final filter = context.read<DateFilterCubit>().state;
            context.read<TransactionsBloc>().add(
              TransactionsLoadRequested(
                year: filter.year,
                month: filter.month,
                forceRefresh: true,
              ),
            );
          }
        },
        child: BlocListener<DateFilterCubit, DateFilterState>(
          listener: (context, filter) {
            context.read<TransactionsBloc>().add(
              TransactionsLoadRequested(
                year: filter.year,
                month: filter.month,
                forceRefresh: true,
              ),
            );
          },
          child: BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, state) {
              if (state is TransactionsLoading) {
                return const LoadingShimmer();
              }
              if (state is TransactionsError) {
                return ErrorView(
                  message: state.failure.message,
                  onRetry: () => context.read<TransactionsBloc>().add(
                    TransactionsLoadRequested(forceRefresh: true),
                  ),
                );
              }
              if (state is TransactionsLoaded) {
                if (state.transactions.isEmpty) {
                  return EmptyState(
                    icon: FontAwesomeIcons.receipt,
                    message: t.transactions.empty,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TransactionsBloc>().add(
                      TransactionsLoadRequested(
                        forceRefresh: true,
                        year: state.selectedYear,
                        month: state.selectedMonth,
                      ),
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = state.transactions[index];
                      return TransactionTile(
                        transaction: transaction,
                        onTap: () => context.push(
                          AppRoutes.transactionById(transaction.id),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'transactions_fab',
          onPressed: () => context.push(AppRoutes.addTransaction),
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
    );
  }
}
