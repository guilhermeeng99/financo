import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Tap-to-open form tile shaped like a "row selector": optional leading
/// widget, label-on-top + value-below text column, trailing chevron.
/// Used by the category, account and linked-account pickers in the
/// transaction and bill forms — replaces the near-identical
/// `_CategoryRow` / `_AccountRow` / `_RowSelector` copies that each form
/// used to ship.
///
/// `value == null` falls back to [placeholder] in the muted onBackground
/// color, communicating "nothing picked yet". Set [isError] to colour
/// the value text in `error` (used today for "category required").
class FinancoPickerField extends StatelessWidget {
  const FinancoPickerField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.leading,
    this.isError = false,
    super.key,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final Widget? leading;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = value != null && value!.isNotEmpty;
    final valueColor = isError
        ? colors.error
        : hasValue
            ? colors.onBackground
            : colors.onBackgroundLight;
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? value! : placeholder,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
