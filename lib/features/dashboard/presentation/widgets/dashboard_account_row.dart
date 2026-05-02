import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Account list row used inside the dashboard sections. More compact
/// than the full accounts-page card.
///
/// When [includedInTotal] is non-null the row prepends a checkbox that
/// controls whether this account contributes to the section total.
/// `null` hides the checkbox entirely (used for credit cards, which
/// have no live total today).
class DashboardAccountRow extends StatelessWidget {
  const DashboardAccountRow({
    required this.account,
    required this.onTap,
    this.includedInTotal,
    this.onToggleIncluded,
    super.key,
  });

  final AccountEntity account;
  final VoidCallback onTap;
  final bool? includedInTotal;
  final VoidCallback? onToggleIncluded;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isCredit = account.type == AccountType.creditCard;
    final amount = isCredit ? account.initialBalance : account.initialBalance;
    final muted = includedInTotal == false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              if (includedInTotal != null) ...[
                _IncludeCheckbox(
                  value: includedInTotal!,
                  onChanged: onToggleIncluded,
                ),
                const SizedBox(width: 6),
              ],
              Opacity(
                opacity: muted ? 0.5 : 1,
                child: BankAvatar(bank: account.bank, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Opacity(
                  opacity: muted ? 0.5 : 1,
                  child: Text(
                    account.name,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: muted ? 0.5 : 1,
                child: Text(
                  formatCurrency(amount),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: amount >= 0 ? colors.income : colors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 11,
                color: colors.onBackgroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncludeCheckbox extends StatelessWidget {
  const _IncludeCheckbox({required this.value, required this.onChanged});

  final bool value;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: 28,
      height: 28,
      child: Checkbox(
        value: value,
        // Compact + matches the row's tap target without dominating it.
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        activeColor: colors.primary,
        onChanged: onChanged == null ? null : (_) => onChanged!(),
      ),
    );
  }
}
