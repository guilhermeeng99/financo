import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Day header for the grouped transactions list. "Today", "Yesterday" or
/// "dd/MM/yyyy" for older dates — same vocabulary as the chat day divider
/// but rendered as a left-aligned section heading rather than a centered
/// chip, since transactions are scrolled in long lists.
class TransactionsDayHeader extends StatelessWidget {
  const TransactionsDayHeader({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Text(
        _label(date).toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: colors.onBackgroundLight,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static String _label(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(messageDay).inDays;
    if (diff == 0) return t.chat.today;
    if (diff == 1) return t.chat.yesterday;
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
