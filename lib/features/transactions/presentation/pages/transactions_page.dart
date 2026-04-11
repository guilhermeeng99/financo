import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/empty_state.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/transaction_tile.dart';
import 'package:financo/core/utils/date_helpers.dart';
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
    context.read<TransactionsBloc>().add(TransactionsLoadRequested());
  }

  void _navigateMonth(int selectedYear, int selectedMonth, int delta) {
    var month = selectedMonth + delta;
    var year = selectedYear;
    if (month < 1) {
      month = 12;
      year--;
    } else if (month > 12) {
      month = 1;
      year++;
    }
    context.read<TransactionsBloc>().add(
      TransactionsLoadRequested(forceRefresh: true, year: year, month: month),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoAppBar(title: t.transactions.title),
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
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
            return Column(
              children: [
                _MonthYearSelector(
                  year: state.selectedYear,
                  month: state.selectedMonth,
                  onPrevious: () => _navigateMonth(
                    state.selectedYear,
                    state.selectedMonth,
                    -1,
                  ),
                  onNext: () => _navigateMonth(
                    state.selectedYear,
                    state.selectedMonth,
                    1,
                  ),
                ),
                Expanded(
                  child: state.transactions.isEmpty
                      ? EmptyState(
                          icon: FontAwesomeIcons.receipt,
                          message: t.transactions.empty,
                        )
                      : RefreshIndicator(
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
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () => context.push(AppRoutes.addTransaction),
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}

class _MonthYearSelector extends StatelessWidget {
  const _MonthYearSelector({
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final label = formatMonthYear(DateTime(year, month));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 18),
            onPressed: onPrevious,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 18),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
