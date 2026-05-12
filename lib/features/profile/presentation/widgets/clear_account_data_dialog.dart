import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/core/extensions/context_extensions.dart';
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
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ClearAccountDataDialog(email: email),
  );
  return result ?? false;
}

class _ClearAccountDataDialog extends StatefulWidget {
  const _ClearAccountDataDialog({required this.email});

  final String email;

  @override
  State<_ClearAccountDataDialog> createState() =>
      _ClearAccountDataDialogState();
}

class _ClearAccountDataDialogState extends State<_ClearAccountDataDialog> {
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
    final colors = context.appColors;
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WarningHeader(colors: colors),
            const SizedBox(height: 16),
            Text(
              t.profile.clearDataConfirmHeadline,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.profile.clearDataConfirmBody,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackgroundLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _EmailChip(email: widget.email, colors: colors),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: t.profile.clearDataConfirmField,
              ),
              onSubmitted: (_) {
                if (_matches) Navigator.pop(context, true);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(t.general.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _matches
                        ? () => Navigator.pop(context, true)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      disabledBackgroundColor: colors.error.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    child: Text(t.general.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningHeader extends StatelessWidget {
  const _WarningHeader({required this.colors});

  final AppColorsData colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: 24,
            color: colors.error,
          ),
        ),
      ),
    );
  }
}

class _EmailChip extends StatelessWidget {
  const _EmailChip({required this.email, required this.colors});

  final String email;
  final AppColorsData colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
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
