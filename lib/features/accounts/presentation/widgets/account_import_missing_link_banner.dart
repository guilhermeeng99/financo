import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Error banner on the accounts import preview listing the credit cards
/// whose linked checking account is neither an existing account nor part
/// of the import batch. The import stays blocked until [missing] is empty.
class AccountImportMissingLinkBanner extends StatelessWidget {
  const AccountImportMissingLinkBanner({required this.missing, super.key});

  final List<String> missing;

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
                  t.accounts.importMissingLinkPrefix,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            missing.join(', '),
            style: context.textTheme.bodySmall?.copyWith(color: colors.error),
          ),
        ],
      ),
    );
  }
}
