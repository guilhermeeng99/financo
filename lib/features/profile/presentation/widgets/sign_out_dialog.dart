import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Confirmation dialog for signing the current user out. Resolves to `true`
/// when the user confirms, `false` on cancel / dismiss.
///
/// Sign out is reversible, so it uses the primary accent rather than the
/// destructive error colour.
Future<bool> showSignOutDialog(BuildContext context) {
  return showFinancoConfirmDialog(
    context,
    icon: FontAwesomeIcons.rightFromBracket,
    title: t.auth.signOut,
    message: t.profile.signOutConfirm,
    confirmLabel: t.auth.signOut,
  );
}
