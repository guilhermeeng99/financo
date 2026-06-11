import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Uppercase, letter-spaced section header used to separate logical groups
/// of cards in long-scrolling pages (payables, future transactions/accounts).
///
/// Example:
///   FinancoSectionHeader(title: 'Overdue', count: 3, accent: colors.expense)
class FinancoSectionHeader extends StatelessWidget {
  const FinancoSectionHeader({
    required this.title,
    this.count,
    this.accent,
    super.key,
  });

  final String title;
  final int? count;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dotColor = accent ?? colors.onBackgroundLight;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: context.textTheme.labelSmall?.copyWith(
                  color: dotColor,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
