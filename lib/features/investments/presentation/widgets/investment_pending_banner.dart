import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InvestmentPendingBanner extends StatelessWidget {
  const InvestmentPendingBanner({
    required this.totalPending,
    required this.onTap,
    super.key,
  });

  final double totalPending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.warning.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 16,
                color: colors.warning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.investments.pendingBannerTitle(
                        amount: formatCurrency(totalPending),
                      ),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.investments.pendingBannerSubtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: colors.onBackgroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
