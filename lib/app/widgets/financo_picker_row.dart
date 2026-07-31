import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// One selectable row inside a `FinancoPickerSheet`: leading avatar/icon,
/// title, optional subtitle, and a check mark plus tinted background when it
/// is the current choice.
///
/// Every picker in the app needs exactly this row, and before the 2026-07-31
/// audit eight of them had each rebuilt it by hand — same
/// `Material > InkWell > Padding > Row`, but drifting on the selected-state
/// alpha (0.08 vs 0.12), the corner radius, and whether the title changed
/// weight when selected. Reach for this instead of hand-rolling a ninth.
///
/// [leading] is a widget rather than an icon so callers can pass a
/// `BankAvatar`, a `FinancoCategoryAvatar`, a plain `FaIcon`, or a coloured
/// disc — the pickers legitimately differ there and nowhere else.
///
/// Example:
/// ```dart
/// FinancoPickerRow(
///   leading: BankAvatar(bank: account.bank),
///   title: account.name,
///   subtitle: account.currency.code,
///   isSelected: account.id == selectedId,
///   onTap: () => Navigator.pop(context, account.id),
/// )
/// ```
class FinancoPickerRow extends StatelessWidget {
  const FinancoPickerRow({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.leading,
    this.subtitle,
    this.indent = 0,
    super.key,
  });

  /// Primary label. Ellipsised on overflow — picker sheets are narrow.
  final String title;

  /// Optional secondary label under [title] (account type, currency, target…).
  final String? subtitle;

  /// Optional leading widget, typically a 40px avatar or icon disc.
  final Widget? leading;

  /// Highlights the row and shows the check mark.
  final bool isSelected;

  /// Extra left padding, used to nest a subcategory under its parent in the
  /// category picker. Zero for a flat list.
  final double indent;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12 + indent, 10, 12, 10),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.onBackgroundLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                FaIcon(
                  FontAwesomeIcons.check,
                  size: 14,
                  color: colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
