import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Sticky bottom bar carrying the primary submit action of a form. Used as
/// `Scaffold.bottomNavigationBar` so the keyboard pushes it up instead of
/// covering it. The button is full-width, 52 tall, with the app's primary
/// fill and a subtle hairline above the bar to detach it from the body.
///
/// Optionally renders a smaller square secondary action (e.g. a "+" for
/// "save and add another") to the right of the primary button. The
/// secondary action shares the enabled/loading state of the primary so a
/// form is never half-actionable.
class FinancoSubmitBar extends StatelessWidget {
  const FinancoSubmitBar({
    required this.label,
    required this.onSubmit,
    this.isLoading = false,
    this.isEnabled = true,
    this.leading,
    this.onSecondarySubmit,
    this.secondaryIcon,
    this.secondaryTooltip,
    super.key,
  });

  final String label;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isEnabled;
  final Widget? leading;

  /// When non-null (together with [secondaryIcon]), a small square button
  /// appears to the right of the primary one. Shares enabled/loading
  /// state so a single in-flight submission disables both.
  final VoidCallback? onSecondarySubmit;
  final IconData? secondaryIcon;
  final String? secondaryTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasLeading = leading != null;
    final hasSecondary = onSecondarySubmit != null && secondaryIcon != null;
    final canPress = isEnabled && !isLoading;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.surfaceVariant, width: 0.5),
        ),
      ),
      child: SizedBox(
        height: 52,
        // Stretch so the primary FilledButton (which has its own smaller
        // intrinsic height) fills the bar instead of centering inside it
        // and looking shorter than the fixed-size secondary action.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasLeading) ...[
              SizedBox(width: 52, height: 52, child: leading),
              const SizedBox(width: 12),
            ],
            Expanded(child: _buildPrimary(colors, canPress: canPress)),
            if (hasSecondary) ...[
              const SizedBox(width: 12),
              _buildSecondary(colors, canPress: canPress),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimary(AppColorsData colors, {required bool canPress}) {
    return FilledButton(
      onPressed: canPress ? onSubmit : null,
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        disabledBackgroundColor: colors.primary.withValues(alpha: 0.4),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildSecondary(AppColorsData colors, {required bool canPress}) {
    final button = SizedBox(
      width: 52,
      height: 52,
      child: FilledButton(
        onPressed: canPress ? onSecondarySubmit : null,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Icon(secondaryIcon, size: 20),
      ),
    );
    final tooltip = secondaryTooltip;
    if (tooltip == null || tooltip.isEmpty) return button;
    return Tooltip(message: tooltip, child: button);
  }
}
