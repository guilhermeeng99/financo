import 'package:financo/app/widgets/financo_app_bar_icon_button.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// App bar of the transaction form. The title flips between add/edit based
/// on [TransactionFormState.isEditing]; in edit mode a trash action calls
/// [onDelete] with the existing transaction id.
class TransactionFormAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const TransactionFormAppBar({required this.onDelete, super.key});

  final ValueChanged<String> onDelete;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      title: BlocBuilder<TransactionFormCubit, TransactionFormState>(
        builder: (context, state) {
          final label = state.isEditing
              ? t.transactions.editTransaction
              : t.transactions.addTransaction;
          return Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
      actions: [
        BlocBuilder<TransactionFormCubit, TransactionFormState>(
          builder: (context, state) {
            if (!state.isEditing) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FinancoAppBarIconButton(
                icon: FontAwesomeIcons.trash,
                color: colors.error,
                tooltip: t.general.delete,
                onPressed: () => onDelete(state.existingId!),
              ),
            );
          },
        ),
      ],
    );
  }
}
