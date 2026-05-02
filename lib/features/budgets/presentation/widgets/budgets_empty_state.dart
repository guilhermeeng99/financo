import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// First-impression empty state for the Budgets tab. Mirrors the
/// `BillsEmptyState` / `CategoriesEmptyState` shape (icon disc → headline
/// → explanatory body → primary CTA) so the feature feels at home in the
/// app.
///
/// The body intentionally does the explaining the screenshot screenshot
/// review flagged was missing: a short pitch of what budgets *do* and a
/// concrete example so the user immediately understands the concept.
class BudgetsEmptyState extends StatelessWidget {
  const BudgetsEmptyState({required this.onAddPressed, super.key});

  final VoidCallback onAddPressed;

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
                  FontAwesomeIcons.bullseye,
                  size: 32,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.budgets.emptyTitle,
              style: context.textTheme.headlineSmall?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.budgets.emptyBody,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackgroundLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
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
                t.budgets.emptyExample,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onBackgroundLight,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
              label: Text(t.budgets.emptyAction),
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
