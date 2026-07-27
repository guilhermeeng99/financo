import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Shows a scrollable single-choice option picker in a [FinancoPickerSheet] and
/// returns the picked option (or null when dismissed). One shared body so the
/// investing forms don't each re-declare the same sheet.
///
/// Example:
/// ```dart
/// final kind = await showOptionPickerSheet<AssetKind>(
///   context: context,
///   title: t.investing.assets.kind,
///   options: AssetKind.selectableKinds,
///   selected: _kind,
///   label: assetKindLabel,
/// );
/// ```
Future<T?> showOptionPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T) label,
}) {
  final colors = context.appColors;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => FinancoPickerSheet(
      title: title,
      bodyBuilder: (scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          for (final option in options)
            ListTile(
              title: Text(label(option)),
              trailing: option == selected
                  ? FaIcon(
                      FontAwesomeIcons.check,
                      size: 14,
                      color: colors.primary,
                    )
                  : null,
              onTap: () => Navigator.pop(ctx, option),
            ),
        ],
      ),
    ),
  );
}
