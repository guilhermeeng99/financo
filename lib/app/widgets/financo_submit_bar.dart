import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Sticky bottom bar carrying the primary submit action of a form. Used as
/// `Scaffold.bottomNavigationBar` so the keyboard pushes it up instead of
/// covering it. The button is full-width, 52 tall, with the app's primary
/// fill and a subtle hairline above the bar to detach it from the body.
class FinancoSubmitBar extends StatelessWidget {
  const FinancoSubmitBar({
    required this.label,
    required this.onSubmit,
    this.isLoading = false,
    this.isEnabled = true,
    super.key,
  });

  final String label;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
        child: FilledButton(
          onPressed: isEnabled && !isLoading ? onSubmit : null,
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
        ),
      ),
    );
  }
}
