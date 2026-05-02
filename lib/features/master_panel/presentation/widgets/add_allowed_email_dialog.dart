import 'package:financo/core/utils/validators.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: Text(t.masterPanel.addEmailTitle),
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
                border: const OutlineInputBorder(),
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: t.masterPanel.addEmailNoteLabel,
                hintText: t.masterPanel.addEmailNoteHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.general.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(t.general.add),
        ),
      ],
    );
  }
}
