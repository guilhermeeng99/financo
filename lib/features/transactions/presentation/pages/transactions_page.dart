import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/empty_state.dart';
import 'package:financo/app/widgets/error_view.dart';
import 'package:financo/app/widgets/financo_app_bar.dart';
import 'package:financo/app/widgets/loading_shimmer.dart';
import 'package:financo/app/widgets/transaction_tile.dart';
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
    context.read<TransactionsBloc>().add(const TransactionsLoadRequested());
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
                const TransactionsLoadRequested(forceRefresh: true),
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
                  const TransactionsLoadRequested(forceRefresh: true),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () => context.push(AppRoutes.addTransaction),
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}
