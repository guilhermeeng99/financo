import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/dashboard/presentation/widgets/dashboard_row_parts.dart';
import 'package:financo/gen/i18n/strings.g.dart';
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
    this.brlEstimate,
    super.key,
  });

  final AccountEntity account;
  final VoidCallback onTap;
  final bool? includedInTotal;
  final VoidCallback? onToggleIncluded;

  /// BRL estimate of the (foreign) account balance, shown as an `≈ R$` sub-line
  /// under the native amount. Null for BRL accounts (F9).
  final double? brlEstimate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // The repository pre-adjusts `initialBalance` into the live balance for
    // every account type (credit cards included, with their own sign), so the
    // row just renders it directly.
    final amount = account.initialBalance;
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
                DashboardIncludeCheckbox(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        account.name,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Type tag sits below the name so long account
                      // names get the full row width instead of being
                      // truncated by the pill. Credit cards skip the
                      // tag because they already sit in their own
                      // section.
                      if (account.type != AccountType.creditCard) ...[
                        const SizedBox(height: 4),
                        _AccountTypeTag(type: account.type),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: muted ? 0.5 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatMoney(Money.fromMajor(amount, account.currency)),
                      style: context.textTheme.titleSmall?.copyWith(
                        color: amount >= 0 ? colors.income : colors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (account.currency != Currency.brl &&
                        brlEstimate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '≈ ${formatCurrency(brlEstimate!)}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                      ),
                    ],
                  ],
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

/// Compact pill rendered next to the account name indicating whether
/// the row is a checking account or an investment account. Colour
/// tracks the same accents the dashboard uses for those types
/// elsewhere (primary for checking, income/green for investment) so
/// the user builds a single visual vocabulary across the app.
class _AccountTypeTag extends StatelessWidget {
  const _AccountTypeTag({required this.type});

  final AccountType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (label, tint) = switch (type) {
      AccountType.checking => (t.accounts.checkingShort, colors.primary),
      AccountType.investment => (t.accounts.investmentShort, colors.income),
      AccountType.creditCard => (t.accounts.creditCard, colors.warning),
    };
    return DashboardPill(label: label, tint: tint);
  }
}
