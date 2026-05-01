import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Wrapper for a group of read-only key/value rows on the account detail
/// page. Renders an uppercase label followed by a rounded surface card that
/// stacks each [AccountDetailRow] with subtle hairline separators.
class AccountDetailSection extends StatelessWidget {
  const AccountDetailSection({
    required this.label,
    required this.rows,
    super.key,
  });

  final String label;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
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
            children: _withSeparators(rows, colors.surfaceVariant),
          ),
        ),
      ],
    );
  }

  static List<Widget> _withSeparators(List<Widget> rows, Color separator) {
    if (rows.length <= 1) return rows;
    final out = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      out.add(rows[i]);
      if (i < rows.length - 1) {
        out.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 0.5, color: separator),
          ),
        );
      }
    }
    return out;
  }
}

class AccountDetailRow extends StatelessWidget {
  const AccountDetailRow({
    required this.label,
    this.value,
    this.child,
    super.key,
  });

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          DefaultTextStyle.merge(
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
            child: child ?? Text(value ?? ''),
          ),
        ],
      ),
    );
  }
}
