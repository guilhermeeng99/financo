import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Asks how far an edit/delete of a recurring transaction should reach:
/// only this occurrence or this and all following ones. Resolves to the
/// picked [TransactionSequenceScope], or `null` when cancelled/dismissed.
/// [deleting] switches copy and styling between the delete and edit flows.
///
/// ```dart
/// final scope = await showTransactionSequenceScopeDialog(
///   context,
///   deleting: true,
/// );
/// ```
Future<TransactionSequenceScope?> showTransactionSequenceScopeDialog(
  BuildContext context, {
  required bool deleting,
}) {
  return showDialog<TransactionSequenceScope>(
    context: context,
    builder: (ctx) => FinancoDialog(
      icon: deleting ? FontAwesomeIcons.trashCan : FontAwesomeIcons.pen,
      iconColor: deleting ? ctx.appColors.error : ctx.appColors.primary,
      title: deleting
          ? t.transactions.sequenceDeleteTitle
          : t.transactions.sequenceEditTitle,
      message: deleting
          ? t.transactions.sequenceDeleteMessage
          : t.transactions.sequenceEditMessage,
      actions: [
        FinancoDialogAction(
          label: t.general.cancel,
          onPressed: () => Navigator.pop(ctx),
        ),
        FinancoDialogAction(
          label: deleting
              ? t.transactions.sequenceDeleteOnlyThis
              : t.transactions.sequenceEditOnlyThis,
          kind: deleting
              ? FinancoDialogActionKind.destructive
              : FinancoDialogActionKind.secondary,
          onPressed: () =>
              Navigator.pop(ctx, TransactionSequenceScope.onlyThis),
        ),
        FinancoDialogAction(
          label: deleting
              ? t.transactions.sequenceDeleteThisAndFollowing
              : t.transactions.sequenceEditThisAndFollowing,
          kind: deleting
              ? FinancoDialogActionKind.destructive
              : FinancoDialogActionKind.primary,
          onPressed: () => Navigator.pop(
            ctx,
            TransactionSequenceScope.thisAndFollowing,
          ),
        ),
      ],
    ),
  );
}
