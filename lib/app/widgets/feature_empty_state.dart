import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Shared first-impression empty state: tinted icon disc (or a custom
/// [leading] widget), headline, supporting message, then an optional
/// muted example chip, primary call-to-action and [footer].
///
/// Example:
/// ```dart
/// FeatureEmptyState(
///   icon: FontAwesomeIcons.tags,
///   title: t.categories.emptyTitle,
///   message: t.categories.empty,
///   actionLabel: t.categories.addFirst,
///   onAction: _openAdd,
/// )
/// ```
class FeatureEmptyState extends StatelessWidget {
  /// Creates the empty state. Provide [icon] for the standard tinted
  /// disc, or [leading] for a custom hero widget.
  const FeatureEmptyState({
    required this.title,
    required this.message,
    this.icon,
    this.leading,
    this.example,
    this.actionLabel,
    this.onAction,
    this.footer,
    this.messageLineHeight,
    this.actionGap = 24,
    this.padding = const EdgeInsets.symmetric(horizontal: 32),
    super.key,
  }) : assert(
         icon != null || leading != null,
         'Provide an icon or a custom leading widget.',
       );

  /// Headline under the icon disc.
  final String title;

  /// Supporting copy under the headline.
  final String message;

  /// Glyph rendered inside the standard tinted disc. Ignored when
  /// [leading] is given.
  final FaIconData? icon;

  /// Custom hero widget replacing the icon disc (e.g. a brand avatar).
  final Widget? leading;

  /// Optional muted chip with a quick concrete example. Skip when the
  /// body itself already names examples.
  final String? example;

  /// Label of the primary call-to-action. No button when `null`.
  final String? actionLabel;

  /// Tap handler of the call-to-action; required when [actionLabel] is
  /// given.
  final VoidCallback? onAction;

  /// Extra content rendered after the call-to-action (suggestion pills,
  /// secondary links…).
  final Widget? footer;

  /// Line height of [message]; long explanatory bodies pass `1.5`.
  final double? messageLineHeight;

  /// Gap between the last text block and the call-to-action.
  final double actionGap;

  /// Outer padding around the whole block.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading ?? _IconDisc(icon: icon!),
            const SizedBox(height: 24),
            _Headline(title: title),
            const SizedBox(height: 8),
            _Message(message: message, lineHeight: messageLineHeight),
            if (example != null) ...[
              const SizedBox(height: 16),
              _ExampleChip(example: example!),
            ],
            if (actionLabel != null) ...[
              SizedBox(height: actionGap),
              _ActionButton(label: actionLabel!, onPressed: onAction),
            ],
            ?footer,
          ],
        ),
      ),
    );
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.icon});

  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: FaIcon(icon, size: 32, color: colors.primary),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.headlineSmall?.copyWith(
        color: context.appColors.onBackground,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.lineHeight});

  final String message;
  final double? lineHeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.appColors.onBackgroundLight,
        height: lineHeight,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ExampleChip extends StatelessWidget {
  const _ExampleChip({required this.example});

  final String example;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        example,
        style: context.textTheme.bodySmall?.copyWith(
          color: colors.onBackgroundLight,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: context.appColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
