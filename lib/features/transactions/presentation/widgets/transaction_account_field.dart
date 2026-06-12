import 'package:financo/app/widgets/financo_picker_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/presentation/cubit/accounts_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Read-only picker field on the transaction form showing the currently
/// selected account (resolved by id from [AccountsCubit]) and opening the
/// account picker via [onTap]. The label adapts to the calling context —
/// "Account", "Source account", "Destination account".
class TransactionAccountField extends StatelessWidget {
  const TransactionAccountField({
    required this.label,
    required this.selectedId,
    required this.onTap,
    super.key,
  });

  final String label;
  final String selectedId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = selectedId.isEmpty
        ? null
        : context
              .watch<AccountsCubit>()
              .state
              .accountsOrEmpty
              .where((a) => a.id == selectedId)
              .firstOrNull;
    return FinancoPickerField(
      label: label,
      value: selected?.name,
      placeholder: t.transactions.account,
      leading: FaIcon(
        selected?.type == AccountType.creditCard
            ? FontAwesomeIcons.creditCard
            : FontAwesomeIcons.buildingColumns,
        size: 14,
        color: colors.onBackgroundLight,
      ),
      onTap: onTap,
    );
  }
}
