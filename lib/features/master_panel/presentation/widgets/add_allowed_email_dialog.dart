import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/core/utils/validators.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddAllowedEmailResult {
  AddAllowedEmailResult({required this.email, this.note});

  final String email;
  final String? note;
}

/// Form dialog used by the master to add a new email to the allowlist.
/// Returns null if the dialog was dismissed.
Future<AddAllowedEmailResult?> showAddAllowedEmailDialog(
  BuildContext context,
) {
  return showDialog<AddAllowedEmailResult>(
    context: context,
    builder: (_) => const _AddAllowedEmailDialog(),
  );
}

class _AddAllowedEmailDialog extends StatefulWidget {
  const _AddAllowedEmailDialog();

  @override
  State<_AddAllowedEmailDialog> createState() => _AddAllowedEmailDialogState();
}

class _AddAllowedEmailDialogState extends State<_AddAllowedEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final note = _noteController.text.trim();
    Navigator.pop(
      context,
      AddAllowedEmailResult(
        email: _emailController.text.trim(),
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FinancoDialog(
      icon: FontAwesomeIcons.userPlus,
      title: t.masterPanel.addEmailTitle,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: t.auth.email,
                hintText: t.auth.emailHint,
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: t.masterPanel.addEmailNoteLabel,
                hintText: t.masterPanel.addEmailNoteHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        FinancoDialogAction(
          label: t.general.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        FinancoDialogAction(
          label: t.general.add,
          kind: FinancoDialogActionKind.primary,
          onPressed: _submit,
        ),
      ],
    );
  }
}
