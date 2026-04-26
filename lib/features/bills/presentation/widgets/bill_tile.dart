import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BillTile extends StatelessWidget {
  const BillTile({
    required this.bill,
    required this.onTap,
    required this.onPayPressed,
    super.key,
  });

  final BillEntity bill;
  final VoidCallback onTap;
  final VoidCallback onPayPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPaid = bill.isPaid;
    final isOverdue = bill.isOverdue;
    final isDueToday = bill.isDueToday;

    final accentColor = isPaid
        ? colors.income
        : isOverdue
            ? colors.expense
            : isDueToday
                ? Colors.orange
                : colors.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: accentColor.withValues(alpha: 0.15),
                    child: FaIcon(
                      _iconFor(bill),
                      color: accentColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.description,
                          style: context.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitleFor(context, bill),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency(bill.amount),
                    style: context.textTheme.titleSmall?.copyWith(
                      color: isPaid
                          ? colors.onBackgroundLight
                          : colors.onBackground,
                      decoration:
                          isPaid ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
              if (!isPaid) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onPayPressed,
                    icon: const FaIcon(FontAwesomeIcons.check, size: 14),
                    label: Text(t.bills.markAsPaid),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static FaIconData _iconFor(BillEntity bill) {
    if (bill.isPaid) return FontAwesomeIcons.circleCheck;
    if (bill.recurrence == BillRecurrence.monthly) {
      return FontAwesomeIcons.arrowsRotate;
    }
    return FontAwesomeIcons.fileInvoiceDollar;
  }

  static String _subtitleFor(BuildContext context, BillEntity bill) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(bill.dueDate);

    if (bill.isPaid) {
      return '${t.bills.paid} • $dateLabel';
    }

    if (bill.isOverdue) {
      final today = DateTime.now();
      final daysOverdue = DateTime(today.year, today.month, today.day)
          .difference(
            DateTime(bill.dueDate.year, bill.dueDate.month, bill.dueDate.day),
          )
          .inDays;
      return t.bills.daysOverdue(days: daysOverdue);
    }

    if (bill.isDueToday) {
      return t.bills.dueToday;
    }

    final today = DateTime.now();
    final dueOnly =
        DateTime(bill.dueDate.year, bill.dueDate.month, bill.dueDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysUntil = dueOnly.difference(todayOnly).inDays;
    if (daysUntil == 1) return '$dateLabel • ${t.bills.dueTomorrow}';
    return '$dateLabel • ${t.bills.dueInDays(days: daysUntil)}';
  }
}
