import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/core/extensions/context_extensions.dart';
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
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _DeleteUserDialog(
      targetEmail: targetEmail,
      targetName: targetName,
    ),
  );
  return result ?? false;
}

class _DeleteUserDialog extends StatefulWidget {
  const _DeleteUserDialog({
    required this.targetEmail,
    required this.targetName,
  });

  final String targetEmail;
  final String targetName;

  @override
  State<_DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<_DeleteUserDialog> {
  final _controller = TextEditingController();
  bool _matches = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final next = _controller.text.trim().toLowerCase() ==
        widget.targetEmail.toLowerCase();
    if (next != _matches) setState(() => _matches = next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FinancoDialog(
      icon: FontAwesomeIcons.userXmark,
      iconColor: colors.error,
      title: t.masterPanel.deleteUserTitle,
      message: t.masterPanel.deleteUserBody(name: widget.targetName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.targetEmail,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: t.masterPanel.deleteUserConfirmField,
              hintText: widget.targetEmail,
            ),
          ),
        ],
      ),
      actions: [
        FinancoDialogAction(
          label: t.general.cancel,
          onPressed: () => Navigator.pop(context, false),
        ),
        FinancoDialogAction(
          label: t.general.delete,
          kind: FinancoDialogActionKind.destructive,
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
        ),
      ],
    );
  }
}
