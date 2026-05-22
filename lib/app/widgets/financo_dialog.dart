import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Visual weight of a [FinancoDialogAction] button. Drives which button
/// style (and colour) the dialog renders.
enum FinancoDialogActionKind {
  /// Filled primary-accent button — the main affirmative action.
  primary,

  /// Outlined neutral button — cancel / secondary choices.
  secondary,

  /// Filled error-accent button — irreversible / destructive action.
  destructive,
}

/// One button in a [FinancoDialog] footer.
///
/// `onPressed == null` renders the button disabled — used by type-to-confirm
/// dialogs that gate the affirmative action until input is valid.
class FinancoDialogAction {
  const FinancoDialogAction({
    required this.label,
    required this.onPressed,
    this.kind = FinancoDialogActionKind.secondary,
  });

  final String label;
  final VoidCallback? onPressed;
  final FinancoDialogActionKind kind;
}

/// Design-system dialog shell shared by every modal in the app so they all
/// speak the same visual language: rounded surface, optional circular icon
/// badge, centred title + body, and a consistent footer button layout.
///
/// Layout of [actions]:
/// * 1 action  → single full-width button.
/// * 2 actions → side-by-side row (equal width).
/// * 3+ actions → stacked full-width buttons, in the given order.
///
/// Example:
/// ```dart
/// showDialog<bool>(
///   context: context,
///   builder: (ctx) => FinancoDialog(
///     icon: FontAwesomeIcons.trashCan,
///     iconColor: ctx.appColors.error,
///     title: t.general.delete,
///     message: t.bills.deleteConfirm,
///     actions: [
///       FinancoDialogAction(
///         label: t.general.cancel,
///         onPressed: () => Navigator.pop(ctx, false),
///       ),
///       FinancoDialogAction(
///         label: t.general.delete,
///         kind: FinancoDialogActionKind.destructive,
///         onPressed: () => Navigator.pop(ctx, true),
///       ),
///     ],
///   ),
/// );
/// ```
class FinancoDialog extends StatelessWidget {
  const FinancoDialog({
    required this.title,
    required this.actions,
    this.icon,
    this.iconColor,
    this.message,
    this.content,
    this.maxWidth = 420,
    super.key,
  });

  /// Bold, centred headline.
  final String title;

  /// Footer buttons. Must not be empty.
  final List<FinancoDialogAction> actions;

  /// Optional glyph rendered in a tinted circular badge above the title.
  final FaIconData? icon;

  /// Tint for the icon badge. Defaults to the primary accent.
  final Color? iconColor;

  /// Optional supporting text under the title.
  final String? message;

  /// Optional extra content (fields, chips…) below the message.
  final Widget? content;

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icon != null) ...[
                _IconBadge(icon: icon!, color: iconColor ?? colors.primary),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackgroundLight,
                    height: 1.4,
                  ),
                ),
              ],
              if (content != null) ...[
                const SizedBox(height: 20),
                content!,
              ],
              const SizedBox(height: 24),
              _ActionButtons(actions: actions),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final FaIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Center(child: FaIcon(icon, size: 22, color: color)),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.actions});

  final List<FinancoDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.length == 1) return _button(context, actions.first);
    if (actions.length == 2) {
      return Row(
        children: [
          Expanded(child: _button(context, actions[0])),
          const SizedBox(width: 12),
          Expanded(child: _button(context, actions[1])),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _button(context, actions[i]),
        ],
      ],
    );
  }

  Widget _button(BuildContext context, FinancoDialogAction action) {
    final colors = context.appColors;
    final label = Text(action.label);
    switch (action.kind) {
      case FinancoDialogActionKind.primary:
        return FilledButton(onPressed: action.onPressed, child: label);
      case FinancoDialogActionKind.destructive:
        return FilledButton(
          onPressed: action.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            disabledBackgroundColor: colors.error.withValues(alpha: 0.3),
          ),
          child: label,
        );
      case FinancoDialogActionKind.secondary:
        return OutlinedButton(onPressed: action.onPressed, child: label);
    }
  }
}

/// Shows a two-button confirm dialog and resolves to `true` only when the
/// user taps the affirmative action. Cancel / dismiss resolve to `false`.
///
/// Set [destructive] for irreversible actions — switches the icon badge and
/// confirm button to the error accent.
Future<bool> showFinancoConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  FaIconData? icon,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => FinancoDialog(
      icon: icon,
      iconColor: destructive ? ctx.appColors.error : ctx.appColors.primary,
      title: title,
      message: message,
      actions: [
        FinancoDialogAction(
          label: cancelLabel ?? t.general.cancel,
          onPressed: () => Navigator.pop(ctx, false),
        ),
        FinancoDialogAction(
          label: confirmLabel,
          kind: destructive
              ? FinancoDialogActionKind.destructive
              : FinancoDialogActionKind.primary,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Shows a single-button informational dialog (e.g. an error message).
Future<void> showFinancoMessageDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? buttonLabel,
  FaIconData? icon,
  Color? iconColor,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => FinancoDialog(
      icon: icon,
      iconColor: iconColor,
      title: title,
      message: message,
      actions: [
        FinancoDialogAction(
          label: buttonLabel ?? t.general.ok,
          kind: FinancoDialogActionKind.primary,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}
