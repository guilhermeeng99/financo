import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Uppercase section label + rounded card containing the section's rows.
/// Children share the card; the wrapper inserts a 1px hairline separator
/// between consecutive rows so the section reads as a tight group.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    required this.label,
    required this.children,
    super.key,
  });

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 4, 8),
          child: Text(
            label.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withSeparators(children, colors.surfaceVariant),
          ),
        ),
      ],
    );
  }

  static List<Widget> _withSeparators(List<Widget> rows, Color separator) {
    if (rows.length <= 1) return rows;
    final result = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      result.add(rows[i]);
      if (i < rows.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Container(height: 0.5, color: separator),
          ),
        );
      }
    }
    return result;
  }
}
