import 'package:financo/app/widgets/type_email_to_confirm_dialog.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Type-to-confirm dialog for wiping the signed-in user's data. Resolves
/// to `true` only when the user typed their own email (case-insensitive)
/// and tapped Delete. Falls back to `false` on cancel / dismiss.
///
/// Mirrors the master-panel delete-user flow so a destructive irreversible
/// action always requires the same kind of explicit confirmation.
Future<bool> showClearAccountDataDialog(
  BuildContext context, {
  required String email,
}) {
  return showTypeEmailToConfirmDialog(
    context,
    email: email,
    icon: FontAwesomeIcons.triangleExclamation,
    title: t.profile.clearDataConfirmHeadline,
    message: t.profile.clearDataConfirmBody,
    fieldLabel: t.profile.clearDataConfirmField,
    barrierDismissible: false,
  );
}
