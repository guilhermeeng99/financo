import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Hero card for the account detail / statement pages: bank avatar, name,
/// type, and the balance in a single rounded surface. Replaces the previous
/// centered amount + label layout that didn't establish identity.
class AccountBalanceCard extends StatelessWidget {
  const AccountBalanceCard({
    required this.account,
    required this.balance,
    this.showCreditMeta = false,
    super.key,
  });

  final AccountEntity account;
  final double balance;

  /// When true and the account is a credit card, renders a compact
  /// metadata strip (credit limit / closing day / due day) below the
  /// balance. Used on mobile to fold the "CREDIT CARD" detail section
  /// into the hero card so the transactions list keeps most of the
  /// viewport instead of being squeezed by a second details block.
  final bool showCreditMeta;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkMode;
    final isCredit = account.type == AccountType.creditCard;
    final typeLabel = isCredit ? t.accounts.creditCard : t.accounts.checking;

    final decoration = isDark
        ? BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surface,
                colors.primary.withValues(alpha: 0.06),
              ],
            ),
          );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BankAvatar(bank: account.bank),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.bankLabel} · $typeLabel',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isCredit
                ? t.accounts.availableCredit
                : t.accounts.currentBalance,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(balance),
            style: context.textTheme.displaySmall?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showCreditMeta && isCredit) ...[
            const SizedBox(height: 16),
            _CreditMetaStrip(account: account),
          ],
        ],
      ),
    );
  }
}

/// Compact label-on-top / value-below trio that folds the credit-card
/// secondary info (limit, closing day, due day) into the hero card on
/// mobile. Uses `Wrap` so the items break to a second row on very narrow
/// screens instead of overflowing.
class _CreditMetaStrip extends StatelessWidget {
  const _CreditMetaStrip({required this.account});

  final AccountEntity account;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: [
        _CreditMetaItem(
          label: t.accounts.creditLimit,
          value: formatCurrency(account.creditLimit ?? 0),
        ),
        _CreditMetaItem(
          label: t.accounts.closingDay,
          value: '${account.closingDay ?? '-'}',
        ),
        _CreditMetaItem(
          label: t.accounts.dueDay,
          value: '${account.dueDay ?? '-'}',
        ),
      ],
    );
  }
}

class _CreditMetaItem extends StatelessWidget {
  const _CreditMetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: colors.onBackgroundLight,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
