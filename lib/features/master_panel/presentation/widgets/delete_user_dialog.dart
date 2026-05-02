import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: Text(t.masterPanel.deleteUserTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.masterPanel.deleteUserBody(name: widget.targetName),
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.targetEmail,
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
            decoration: InputDecoration(
              labelText: t.masterPanel.deleteUserConfirmField,
              hintText: widget.targetEmail,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.general.cancel),
        ),
        FilledButton(
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
          style: FilledButton.styleFrom(backgroundColor: colors.error),
          child: Text(t.general.delete),
        ),
      ],
    );
  }
}
