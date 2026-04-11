import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/app/widgets/financo_button.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:financo/features/transactions/presentation/bloc/transactions_event_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({required this.transactionId, super.key});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        TransactionEntity? transaction;
        if (state is TransactionsLoaded) {
          transaction = state.transactions
              .where((t) => t.id == transactionId)
              .firstOrNull;
        }

        if (transaction == null) {
          return Scaffold(
            appBar: AppBar(title: Text(t.transactions.transaction)),
            body: Center(child: Text(t.transactions.transactionNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(t.transactions.transactionDetails),
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.trashCan),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(t.transactions.deleteTransaction),
                      content: Text(
                        t.transactions.deleteConfirm,
                      ),
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
                  if (confirmed == true && context.mounted) {
                    context.read<TransactionsBloc>().add(
                      TransactionDeleteRequested(transactionId),
                    );
                    context.pop();
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: AmountText(
                    amount: transaction.amount,
                    isIncome: transaction.type == TransactionType.income,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 24),
                _DetailRow(
                  label: t.transactions.description,
                  value: transaction.description,
                ),
                _DetailRow(
                  label: t.transactions.type,
                  value: transaction.type == TransactionType.income
                      ? t.transactions.income
                      : t.transactions.expense,
                ),
                _DetailRow(
                  label: t.transactions.date,
                  value: formatDate(transaction.date),
                ),
                _DetailRow(
                  label: t.transactions.reconciled,
                  value: transaction.isReconciled
                      ? t.general.yes
                      : t.general.no,
                ),
                if (transaction.notes?.isNotEmpty ?? false)
                  _DetailRow(
                    label: t.transactions.notes,
                    value: transaction.notes ?? '',
                  ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: FinancoButton(
                        label: transaction.isReconciled
                            ? t.transactions.unreconcile
                            : t.transactions.reconcile,
                        isOutlined: true,
                        onPressed: () {
                          context.read<TransactionsBloc>().add(
                            TransactionReconcileToggled(transactionId),
                          );
                          context.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
