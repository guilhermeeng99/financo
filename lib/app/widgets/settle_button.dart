import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Square check button that settles a pending transaction in one tap.
///
/// Shared by the payables/receivables ledger and the account statement so
/// both offer the same affordance and the same accent rule — green for a
/// receivable, red for a payable, matching the row's amount.
///
/// The caller owns the action: it decides whether the row is settleable and
/// runs `SettleTransactionUseCase`, which stamps today as `settledAt` and
/// leaves the row's `date` on its `dueDate`.
///
/// ```dart
/// SettleButton(
///   transaction: transaction,
///   onPressed: () => _settle(transaction),
/// )
/// ```
class SettleButton extends StatelessWidget {
  const SettleButton({
    required this.transaction,
    required this.onPressed,
    super.key,
  });

  final TransactionEntity transaction;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = transaction.isReceivable ? colors.income : colors.expense;
    return Semantics(
      button: true,
      label: transaction.isReceivable
          ? t.payablesReceivables.markAsReceived
          : t.payablesReceivables.markAsPaid,
      child: Material(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: FaIcon(FontAwesomeIcons.check, size: 14, color: accent),
            ),
          ),
        ),
      ),
    );
  }
}
