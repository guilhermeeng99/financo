import 'package:financo/app/state/form_status.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Toggle on the transaction form submit bar that flips the row between
/// paid/received-now and pending (scheduled). Shows a check when the entry
/// is settled and a clock when it will stay pending; disabled while a
/// submit is in flight.
class TransactionSettlementActionButton extends StatelessWidget {
  const TransactionSettlementActionButton({
    required this.state,
    required this.cubit,
    super.key,
  });

  final TransactionFormState state;
  final TransactionFormCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPaid = state.settlementStatus == TransactionSettlementStatus.paid;
    final isSubmitting = state.status == FormStatus.submitting;
    final paidLabel = state.type == TransactionType.income
        ? t.transactions.receivedNow
        : t.transactions.paidNow;
    final nextStatus = isPaid
        ? TransactionSettlementStatus.pending
        : TransactionSettlementStatus.paid;
    final tooltip = isPaid ? paidLabel : t.transactions.leavePending;
    final foreground = isPaid ? Colors.white : colors.onBackgroundLight;
    final background = isPaid
        ? colors.income
        : colors.surfaceVariant.withValues(alpha: 0.9);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: isPaid,
        label: tooltip,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: isSubmitting
                ? null
                : () => cubit.updateSettlementStatus(nextStatus),
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: FaIcon(
                isPaid ? FontAwesomeIcons.check : FontAwesomeIcons.clock,
                size: 18,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
