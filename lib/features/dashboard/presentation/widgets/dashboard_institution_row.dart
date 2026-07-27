import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/presentation/widgets/dashboard_row_parts.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Dashboard row for a market-valued investment account (an investing
/// institution). Mirrors `DashboardAccountRow` but shows the live market value
/// of the institution's holdings and a native-currency pill. Part of the F8
/// account/investing unification — see
/// `docs/specs/investing_account_unification.md`.
class DashboardInstitutionRow extends StatelessWidget {
  const DashboardInstitutionRow({
    required this.row,
    required this.onTap,
    this.includedInTotal,
    this.onToggleIncluded,
    super.key,
  });

  final InvestmentAccountRow row;
  final VoidCallback onTap;
  final bool? includedInTotal;
  final VoidCallback? onToggleIncluded;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
                child: _InstitutionAvatar(row: row),
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
                        row.name,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _MarketTag(row: row),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: muted ? 0.5 : 1,
                child: _InstitutionAmount(row: row),
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

/// Uses the brand avatar when the institution carries a known `bank` hint,
/// otherwise a coloured initials disc so every broker still has an identity.
class _InstitutionAvatar extends StatelessWidget {
  const _InstitutionAvatar({required this.row});

  final InvestmentAccountRow row;

  BankType? _bankFromName(String? name) {
    if (name == null) return null;
    return BankType.values.where((b) => b.name == name).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final bank = _bankFromName(row.bank);
    if (bank != null) return BankAvatar(bank: bank, size: 36);

    final background = Color(row.color ?? 0xFF6C63FF);
    final foreground = background.computeLuminance() > 0.55
        ? Colors.black
        : Colors.white;
    final initials = _initials(row.name);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}

/// A small pill marking the row as a market-valued investment account, tinted
/// green (income accent) to echo the "money you hold" vocabulary. The native
/// currency is no longer shown here — it moved to the amount column ($ over the
/// `≈ R$` estimate) so this pill can say what the row *is*: an investment.
/// Turns amber when a quote is stale so the user knows the value is last-known.
class _MarketTag extends StatelessWidget {
  const _MarketTag({required this.row});

  final InvestmentAccountRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = row.priceStale ? colors.warning : colors.income;
    return DashboardPill(label: t.dashboard.investmentTag, tint: tint);
  }
}

/// Amount column for an institution row. A BRL institution shows a single
/// `R$` figure; a foreign one (e.g. Avenue in US$) shows its native value with
/// the consolidated `≈ R$` estimate below — matching how foreign cash accounts
/// render (F9). The `≈ R$` line is omitted when no rate consolidated the value
/// (marketValue == 0) so the row shows the real native figure instead of R$ 0.
class _InstitutionAmount extends StatelessWidget {
  const _InstitutionAmount({required this.row});

  final InvestmentAccountRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final code = row.currencyCode;
    final isForeign = code != null && code != Currency.brl.code;

    if (!isForeign) {
      return Text(
        formatCurrency(row.marketValue),
        style: context.textTheme.titleSmall?.copyWith(
          color: row.marketValue >= 0 ? colors.income : colors.expense,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final currency = Currency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => Currency.brl,
    );
    final hasBrlEstimate = row.marketValue != 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatMoney(Money.fromMajor(row.nativeValue, currency)),
          style: context.textTheme.titleSmall?.copyWith(
            color: row.nativeValue >= 0 ? colors.income : colors.expense,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasBrlEstimate) ...[
          const SizedBox(height: 2),
          Text(
            '≈ ${formatCurrency(row.marketValue)}',
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
            ),
          ),
        ],
      ],
    );
  }
}
