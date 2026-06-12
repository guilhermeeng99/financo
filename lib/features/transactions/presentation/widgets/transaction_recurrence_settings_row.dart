import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Periodicity + count/interval pair shown on the transaction form when a
/// recurring option (installment or fixed) is selected. Lays the two fields
/// side by side on wide screens and stacks them on narrow ones.
///
/// [onPickInterval] opens the interval picker (fixed recurrence);
/// [onPickInstallments] opens the installment-count picker (installments).
class TransactionRecurrenceSettingsRow extends StatelessWidget {
  const TransactionRecurrenceSettingsRow({
    required this.state,
    required this.onPickInterval,
    required this.onPickInstallments,
    super.key,
  });

  final TransactionFormState state;
  final VoidCallback onPickInterval;
  final VoidCallback onPickInstallments;

  @override
  Widget build(BuildContext context) {
    final periodicity = _StaticValueField(
      label: t.transactions.periodicity,
      value: t.transactions.periodicityMonthly,
    );
    final variableField = state.recurrence == TransactionRecurrence.installment
        ? _NumberPickerField(
            label: t.transactions.installmentCount,
            value: '${state.installmentCount}',
            onTap: onPickInstallments,
          )
        : _NumberPickerField(
            label: t.transactions.recurrenceIntervalMonths,
            value: '${state.recurrenceIntervalMonths}',
            onTap: onPickInterval,
          );

    if (context.screenSize.width < 520) {
      return Column(
        children: [
          periodicity,
          const SizedBox(height: 12),
          variableField,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: periodicity),
        const SizedBox(width: 12),
        Expanded(child: variableField),
      ],
    );
  }
}

class _StaticValueField extends StatelessWidget {
  const _StaticValueField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberPickerField extends StatelessWidget {
  const _NumberPickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FinancoPickerField(
      label: label,
      value: value,
      placeholder: value,
      leading: FaIcon(
        FontAwesomeIcons.hashtag,
        size: 13,
        color: context.appColors.onBackgroundLight,
      ),
      onTap: onTap,
    );
  }
}
