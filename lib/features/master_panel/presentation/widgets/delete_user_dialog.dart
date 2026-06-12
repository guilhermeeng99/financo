import 'package:financo/app/widgets/type_email_to_confirm_dialog.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Type-to-confirm dialog for cascading user delete. Resolves to `true`
/// when the master typed the target email exactly (case-insensitive)
/// and tapped delete.
Future<bool> showDeleteUserDialog(
  BuildContext context, {
  required String targetEmail,
  required String targetName,
}) {
  return showTypeEmailToConfirmDialog(
    context,
    email: targetEmail,
    icon: FontAwesomeIcons.userXmark,
    title: t.masterPanel.deleteUserTitle,
    message: t.masterPanel.deleteUserBody(name: targetName),
    fieldLabel: t.masterPanel.deleteUserConfirmField,
    fieldHint: targetEmail,
  );
}
