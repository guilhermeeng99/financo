import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// One row in the accounts list. Replaces the Material `Card` with a soft
/// surface tile and adds a subtle credit-card progress indicator showing how
/// much of the limit has been used.
class AccountCard extends StatelessWidget {
  const AccountCard({
    required this.account,
    this.onTap,
    super.key,
  });

  final AccountEntity account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isCredit = account.type == AccountType.creditCard;
    final typeLabel =
        isCredit ? t.accounts.creditCard : t.accounts.checking;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    BankAvatar(bank: account.bank),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: colors.onBackground,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              FaIcon(
                                isCredit
                                    ? FontAwesomeIcons.creditCard
                                    : FontAwesomeIcons.buildingColumns,
                                size: 10,
                                color: colors.onBackgroundLight,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '${account.bankLabel} · $typeLabel',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colors.onBackgroundLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _Amount(account: account),
                  ],
                ),
                if (isCredit && (account.creditLimit ?? 0) > 0) ...[
                  const SizedBox(height: 12),
                  _CreditUsageBar(account: account),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.account});

  final AccountEntity account;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isCredit = account.type == AccountType.creditCard;
    final amount = isCredit
        ? account.availableCredit
        : account.effectiveBalance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatCurrency(amount),
          style: context.textTheme.titleSmall?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (isCredit) ...[
          const SizedBox(height: 2),
          Text(
            t.accounts.availableCredit,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
        ],
      ],
    );
  }
}

class _CreditUsageBar extends StatelessWidget {
  const _CreditUsageBar({required this.account});

  final AccountEntity account;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final limit = account.creditLimit ?? 0;
    final used = account.usedCredit;
    final progress = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    // Tints toward warning then expense as the user gets closer to limit.
    final accent = progress < 0.6
        ? colors.primary
        : progress < 0.85
            ? colors.warning
            : colors.expense;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${formatCurrency(used)} / ${formatCurrency(limit)}',
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: context.textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
