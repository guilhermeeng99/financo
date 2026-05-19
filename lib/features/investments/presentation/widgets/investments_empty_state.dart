import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// First-impression empty state for the Investments tab. Mirrors the
/// `BudgetsEmptyState` / `BillsEmptyState` shape (icon disc → headline
/// → explanatory body → optional example chip → primary CTA) so the
/// feature feels at home in the app.
///
/// Used for two states:
///   * No investment account yet — CTA routes to /accounts/add.
///   * No asset classes yet — CTA opens the asset-class form.
class InvestmentsEmptyState extends StatelessWidget {
  const InvestmentsEmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.example,
    super.key,
  });

  final FaIconData icon;
  final String title;
  final String body;

  /// Optional muted chip with a quick concrete example (matches
  /// `BudgetsEmptyState.emptyExample`). Skip when the body itself
  /// already names examples.
  final String? example;

  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  size: 32,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackgroundLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (example != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  example!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onBackgroundLight,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAction,
              icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
