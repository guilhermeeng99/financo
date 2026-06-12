import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Error banner on the transactions import preview listing the account and
/// category names referenced by the CSV that don't exist yet. The import
/// stays blocked until both lists are empty.
class TransactionImportMissingBanner extends StatelessWidget {
  const TransactionImportMissingBanner({
    required this.missingAccounts,
    required this.missingCategories,
    super.key,
  });

  final List<String> missingAccounts;
  final List<String> missingCategories;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 14,
                color: colors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.transactions.importMissingAfterEditPrefix,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (missingAccounts.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${t.transactions.importMissingAccounts} '
              '${missingAccounts.join(", ")}',
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.error,
              ),
            ),
          ],
          if (missingCategories.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${t.transactions.importMissingCategories} '
              '${missingCategories.join(", ")}',
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
