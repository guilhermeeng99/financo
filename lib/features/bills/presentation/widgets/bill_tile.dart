import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/presentation/widgets/bill_status_dot.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// A single row in the bills list. Tap → triggers [onTap] (currently routes
/// to the edit page; phase 2 will swap this for a detail bottom sheet).
/// Pending bills get a small trailing check button to settle without leaving
/// the list.
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
    final kind = bill.statusKind;
    final accent = billStatusColor(
      context,
      kind,
      isReceivable: bill.isReceivable,
    );
    final isPaid = kind == BillStatusKind.paid;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _IconDisc(icon: _iconFor(bill), color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.description,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: isPaid
                              ? colors.onBackgroundLight
                              : colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitleFor(bill),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: kind == BillStatusKind.overdue ||
                                  kind == BillStatusKind.today
                              ? accent
                              : colors.onBackgroundLight,
                          fontWeight:
                              kind == BillStatusKind.overdue ||
                                      kind == BillStatusKind.today
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _AmountColumn(bill: bill),
                if (!isPaid) ...[
                  const SizedBox(width: 8),
                  _PayButton(onPressed: onPayPressed, color: accent),
                ],
              ],
            ),
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
    if (bill.isReceivable) return FontAwesomeIcons.handHoldingDollar;
    return FontAwesomeIcons.fileInvoiceDollar;
  }

  static String _subtitleFor(BillEntity bill) {
    final dateLabel = DateFormat('dd/MM').format(bill.dueDate);

    if (bill.isPaid) {
      final label = bill.isReceivable ? t.bills.received : t.bills.paid;
      return '$label · $dateLabel';
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

    if (bill.isDueToday) return t.bills.dueToday;

    final today = DateTime.now();
    final dueOnly =
        DateTime(bill.dueDate.year, bill.dueDate.month, bill.dueDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysUntil = dueOnly.difference(todayOnly).inDays;
    final recurrenceSuffix = bill.recurrence == BillRecurrence.monthly
        ? ' · ${t.bills.monthly}'
        : '';

    if (daysUntil == 1) {
      return '${t.bills.dueTomorrow}$recurrenceSuffix';
    }
    return '${t.bills.dueInDays(days: daysUntil)}$recurrenceSuffix';
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.icon, required this.color});

  final FaIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: FaIcon(icon, size: 18, color: color),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({required this.bill});

  final BillEntity bill;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPaid = bill.isPaid;
    return Text(
      formatCurrency(bill.amount),
      style: context.textTheme.titleSmall?.copyWith(
        color: isPaid ? colors.onBackgroundLight : colors.onBackground,
        fontWeight: FontWeight.w600,
        decoration: isPaid ? TextDecoration.lineThrough : null,
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.onPressed, required this.color});

  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: t.bills.markAsPaid,
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: FaIcon(FontAwesomeIcons.check, size: 14, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
