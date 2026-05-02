import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_large_app_bar.dart';
import 'package:financo/app/widgets/lifted_fab.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/transaction_tile.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/features/transactions/presentation/widgets/transactions_day_header.dart';
import 'package:financo/features/transactions/presentation/widgets/transactions_empty_state.dart';
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

  void _openAdd() => context.push(AppRoutes.addTransaction);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinancoLargeAppBar(
        title: t.transactions.title,
        showBack: true,
      ),
      body: BlocListener<TransactionsBloc, TransactionsState>(
        listener: _onTransactionsState,
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
              if (state is TransactionsLoading ||
                  state is TransactionsImporting) {
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
                  return TransactionsEmptyState(onAddPressed: _openAdd);
                }
                return _TransactionsList(state: state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton(
          heroTag: 'transactions_fab',
          onPressed: _openAdd,
          child: const FaIcon(FontAwesomeIcons.plus),
        ),
      ),
    );
  }

  void _onTransactionsState(BuildContext context, TransactionsState state) {
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
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({required this.state});

  final TransactionsLoaded state;

  @override
  Widget build(BuildContext context) {
    final categoryMap = {
      for (final c in context.watch<CategoriesCubit>().state.categoriesOrEmpty)
        c.id: c,
    };
    final accountMap = {
      for (final a in context.watch<AccountsCubit>().state.accountsOrEmpty)
        a.id: a,
    };

    final groups = _groupByDay(state.transactions);

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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final colors = context.appColors;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TransactionsDayHeader(date: group.date),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    for (var i = 0; i < group.items.length; i++) ...[
                      if (i > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: 0.5,
                            color: colors.surfaceVariant,
                          ),
                        ),
                      TransactionTile(
                        transaction: group.items[i],
                        categoryLabel: _categoryLabel(
                          categoryMap,
                          group.items[i].categoryId,
                        ),
                        accountLabel:
                            accountMap[group.items[i].accountId]?.name,
                        onTap: () => context.push(
                          AppRoutes.addTransaction,
                          extra: group.items[i],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String? _categoryLabel(
    Map<String, CategoryEntity> categoryMap,
    String categoryId,
  ) {
    if (categoryId.isEmpty) return null;
    final category = categoryMap[categoryId];
    if (category == null) return null;
    return category.displayPath(categoryMap.values);
  }

  static List<_DayGroup> _groupByDay(List<TransactionEntity> txs) {
    final byDay = <DateTime, List<TransactionEntity>>{};
    for (final tx in txs) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      byDay.putIfAbsent(day, () => []).add(tx);
    }
    final entries = byDay.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries
        .map((e) => _DayGroup(date: e.key, items: e.value))
        .toList();
  }
}

class _DayGroup {
  const _DayGroup({required this.date, required this.items});

  final DateTime date;
  final List<TransactionEntity> items;
}
