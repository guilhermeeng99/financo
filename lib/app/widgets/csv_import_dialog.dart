import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// What the user chose on the CSV-import intro dialog. `null` (from
/// [showCsvImportIntroDialog]) means cancel / dismiss.
enum CsvImportIntroChoice { downloadExample, selectFile }

/// Shared intro dialog for every "import from CSV" flow (transactions, bills,
/// accounts, categories, budgets). Only the strings differ per feature — the
/// layout, icon and button order live here so all five stay identical.
Future<CsvImportIntroChoice?> showCsvImportIntroDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String downloadLabel,
  required String selectLabel,
}) {
  return showDialog<CsvImportIntroChoice>(
    context: context,
    builder: (ctx) => FinancoDialog(
      icon: FontAwesomeIcons.fileCsv,
      title: title,
      message: body,
      actions: [
        FinancoDialogAction(
          label: selectLabel,
          kind: FinancoDialogActionKind.primary,
          onPressed: () => Navigator.pop(ctx, CsvImportIntroChoice.selectFile),
        ),
        FinancoDialogAction(
          label: downloadLabel,
          onPressed: () =>
              Navigator.pop(ctx, CsvImportIntroChoice.downloadExample),
        ),
        FinancoDialogAction(
          label: t.general.cancel,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}

/// Shared error dialog for a failed CSV import / preview.
Future<void> showCsvImportErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showFinancoMessageDialog(
    context,
    icon: FontAwesomeIcons.circleExclamation,
    iconColor: context.appColors.error,
    title: title,
    message: message,
  );
}
