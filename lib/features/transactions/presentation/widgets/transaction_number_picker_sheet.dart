import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Bottom sheet listing the integers [min]..[max] (inclusive) with the
/// current [selected] value checked. Resolves to the tapped number, or
/// `null` when dismissed. Used by the transaction form to pick the
/// installment count and the recurrence interval.
///
/// ```dart
/// final count = await showTransactionNumberPicker(
///   context: context,
///   title: t.transactions.installmentCount,
///   min: 2,
///   max: 48,
///   selected: 12,
/// );
/// ```
Future<int?> showTransactionNumberPicker({
  required BuildContext context,
  required String title,
  required int min,
  required int max,
  required int selected,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: context.appColors.surface,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              title,
              style: ctx.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: max - min + 1,
              itemBuilder: (context, index) {
                final option = min + index;
                return ListTile(
                  selected: option == selected,
                  title: Text('$option'),
                  trailing: option == selected
                      ? const FaIcon(FontAwesomeIcons.check, size: 16)
                      : null,
                  onTap: () => Navigator.pop(ctx, option),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
