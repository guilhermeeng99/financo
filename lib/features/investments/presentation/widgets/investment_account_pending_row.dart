import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/investments/domain/entities/investment_overview.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InvestmentAccountPendingRow extends StatelessWidget {
  const InvestmentAccountPendingRow({
    required this.slice,
    required this.onAllocate,
    super.key,
  });

  final InvestmentAccountSlice slice;
  final VoidCallback onAllocate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = slice.hasOverflow ? colors.expense : colors.warning;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slice.accountName,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slice.hasOverflow
                        ? t.investments.accountOverflow(
                            allocated: formatCurrency(slice.allocated),
                            balance: formatCurrency(slice.balance),
                          )
                        : t.investments.accountPending(
                            amount: formatCurrency(slice.pending),
                          ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: tint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _AllocateChip(onTap: onAllocate),
          ],
        ),
      ),
    );
  }
}

/// Compact filled pill mirroring the action chip used on the
/// `AssetClassDetailPage`. Kept local so this widget stays
/// self-contained, but the visual contract matches the detail page
/// chip 1:1 so users see the same affordance everywhere they
/// allocate.
class _AllocateChip extends StatelessWidget {
  const _AllocateChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.plus,
                size: 11,
                color: colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                t.investments.allocateAction,
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
