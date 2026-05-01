import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Uppercase label + count badge + rounded surface card. The dashboard's
/// equivalent of `FinancoFormSection`, sized to fit content lists rather
/// than form fields (no inner padding so list rows can have their own
/// hover/tap area).
class DashboardSection extends StatelessWidget {
  const DashboardSection({
    required this.label,
    required this.child,
    this.count,
    this.accent,
    this.trailing,
    super.key,
  });

  final String label;
  final Widget child;
  final int? count;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dot = accent ?? colors.onBackgroundLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.onBackgroundLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: dot.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: dot,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ],
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ],
    );
  }
}
