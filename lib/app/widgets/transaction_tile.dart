import 'package:financo/app/widgets/amount_text.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    this.onTap,
    super.key,
  });

  final TransactionEntity transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isIncome = transaction.type == TransactionType.income;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isIncome
            ? colors.income.withValues(alpha: 0.1)
            : colors.expense.withValues(alpha: 0.1),
        child: FaIcon(
          isIncome ? FontAwesomeIcons.arrowDown : FontAwesomeIcons.arrowUp,
          color: isIncome ? colors.income : colors.expense,
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        style: context.textTheme.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        formatDate(transaction.date),
        style: context.textTheme.bodySmall?.copyWith(
          color: colors.onBackgroundLight,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AmountText(
            amount: transaction.amount,
            isIncome: isIncome,
            fontSize: 14,
          ),
          if (transaction.isReconciled) ...[
            const SizedBox(width: 4),
            FaIcon(
              FontAwesomeIcons.solidCircleCheck,
              size: 16,
              color: colors.success,
            ),
          ],
        ],
      ),
    );
  }
}
