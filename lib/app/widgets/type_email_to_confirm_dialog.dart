import 'package:financo/app/widgets/financo_dialog.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Type-to-confirm dialog for destructive, irreversible actions. The
/// user must type [email] exactly (case-insensitive, surrounding
/// whitespace ignored) before the destructive CTA enables. Resolves to
/// `true` only on confirm; cancel / dismiss resolve to `false`.
///
/// * [title] / [message] — headline and supporting copy.
/// * [icon] — glyph of the error-tinted badge above the title.
/// * [fieldLabel] / [fieldHint] — decoration of the confirmation field.
/// * [confirmLabel] — destructive CTA label; defaults to
///   `t.general.delete`.
/// * [barrierDismissible] — whether tapping outside dismisses.
///
/// Example:
/// ```dart
/// final confirmed = await showTypeEmailToConfirmDialog(
///   context,
///   email: user.email,
///   icon: FontAwesomeIcons.userXmark,
///   title: t.masterPanel.deleteUserTitle,
///   message: t.masterPanel.deleteUserBody(name: user.name),
///   fieldLabel: t.masterPanel.deleteUserConfirmField,
/// );
/// ```
Future<bool> showTypeEmailToConfirmDialog(
  BuildContext context, {
  required String email,
  required String title,
  required String message,
  required FaIconData icon,
  required String fieldLabel,
  String? fieldHint,
  String? confirmLabel,
  bool barrierDismissible = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => _TypeEmailToConfirmDialog(
      email: email,
      title: title,
      message: message,
      icon: icon,
      fieldLabel: fieldLabel,
      fieldHint: fieldHint,
      confirmLabel: confirmLabel ?? t.general.delete,
    ),
  );
  return result ?? false;
}

class _TypeEmailToConfirmDialog extends StatefulWidget {
  const _TypeEmailToConfirmDialog({
    required this.email,
    required this.title,
    required this.message,
    required this.icon,
    required this.fieldLabel,
    required this.fieldHint,
    required this.confirmLabel,
  });

  final String email;
  final String title;
  final String message;
  final FaIconData icon;
  final String fieldLabel;
  final String? fieldHint;
  final String confirmLabel;

  @override
  State<_TypeEmailToConfirmDialog> createState() =>
      _TypeEmailToConfirmDialogState();
}

class _TypeEmailToConfirmDialogState
    extends State<_TypeEmailToConfirmDialog> {
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
    final next =
        _controller.text.trim().toLowerCase() == widget.email.toLowerCase();
    if (next != _matches) setState(() => _matches = next);
  }

  @override
  Widget build(BuildContext context) {
    return FinancoDialog(
      icon: widget.icon,
      iconColor: context.appColors.error,
      title: widget.title,
      message: widget.message,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailChip(email: widget.email),
          const SizedBox(height: 16),
          _buildConfirmationField(),
        ],
      ),
      actions: [
        FinancoDialogAction(
          label: t.general.cancel,
          onPressed: () => Navigator.pop(context, false),
        ),
        FinancoDialogAction(
          label: widget.confirmLabel,
          kind: FinancoDialogActionKind.destructive,
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
        ),
      ],
    );
  }

  Widget _buildConfirmationField() {
    return TextField(
      controller: _controller,
      autofocus: true,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: widget.fieldLabel,
        hintText: widget.fieldHint,
      ),
      onSubmitted: (_) {
        if (_matches) Navigator.pop(context, true);
      },
    );
  }
}

class _EmailChip extends StatelessWidget {
  const _EmailChip({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.appColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        email,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
