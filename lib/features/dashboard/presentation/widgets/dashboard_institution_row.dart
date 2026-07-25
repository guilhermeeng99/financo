import 'package:financo/app/widgets/bank_avatar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
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
    final amount = row.marketValue;
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

/// Uses the brand avatar when the institution carries a known `bank` hint,
/// otherwise a coloured initials disc so every broker still has an identity.
class _InstitutionAvatar extends StatelessWidget {
  const _InstitutionAvatar({required this.row});

  final InvestmentAccountRow row;

  BankType? _bankFromName(String? name) {
    if (name == null) return null;
    for (final bank in BankType.values) {
      if (bank.name == name) return bank;
    }
    return null;
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
/// green (income accent) to echo the "money you hold" vocabulary and showing
/// the native currency code.
class _MarketTag extends StatelessWidget {
  const _MarketTag({required this.row});

  final InvestmentAccountRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = row.priceStale ? colors.warning : colors.income;
    final label = row.currencyCode ?? 'BRL';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: tint,
          fontWeight: FontWeight.w700,
          height: 1,
          fontSize: 10,
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
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        activeColor: colors.primary,
        onChanged: onChanged == null ? null : (_) => onChanged!(),
      ),
    );
  }
}
