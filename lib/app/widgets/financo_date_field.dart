import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// Read-only date tile that renders as an `InputDecorator` so it visually
/// matches the surrounding `FinancoTextField`s. Tapping it should open a
/// date picker (or any date-resolving sheet) — the widget itself is just
/// the display.
///
/// Replaces the per-feature `_DateField` copies that transaction forms
/// previously maintained.
class FinancoDateField extends StatelessWidget {
  const FinancoDateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.format = 'dd/MM/yyyy',
    super.key,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  /// Defaults to BR-style `dd/MM/yyyy`. Override only when a feature
  /// genuinely needs a different display format.
  final String format;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          // Vertically center the icon inside the field. Using a bare
          // `Padding` here parks the icon at the top — the field has no
          // intrinsic centering for its suffix.
          suffixIcon: SizedBox(
            width: 44,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.calendar,
                size: 14,
                color: colors.onBackgroundLight,
              ),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              DateFormat(format).format(value),
              maxLines: 1,
              softWrap: false,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
