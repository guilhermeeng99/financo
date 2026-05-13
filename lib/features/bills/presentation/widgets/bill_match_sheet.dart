import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/entities/bill_match_candidate.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Resolves a `categoryId` (which may be null/empty) to a human-readable
/// "Parent › Child" label. The page owns the resolution because that's
/// where `CategoriesCubit` is read.
typedef CategoryLabelResolver = String? Function(String? categoryId);

/// Modal sheet that lists bill ↔ transaction match suggestions and lets
/// the user resolve each pair: confirm (link) or reject (silence).
///
/// The sheet does NOT dispatch events itself — it calls back to the host
/// page so the page owns the BillsBloc and can react to state changes
/// (snackbars, refreshes). This keeps the sheet a pure dumb widget.
class BillMatchSheet extends StatelessWidget {
  const BillMatchSheet({
    required this.candidates,
    required this.onAccept,
    required this.onReject,
    required this.categoryLabelFor,
    super.key,
  });

  final List<BillMatchCandidate> candidates;
  final void Function(BillEntity bill, TransactionEntity tx) onAccept;
  final void Function(BillEntity bill, TransactionEntity tx) onReject;
  final CategoryLabelResolver categoryLabelFor;

  static Future<void> show({
    required BuildContext context,
    required List<BillMatchCandidate> candidates,
    required void Function(BillEntity bill, TransactionEntity tx) onAccept,
    required void Function(BillEntity bill, TransactionEntity tx) onReject,
    required CategoryLabelResolver categoryLabelFor,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BillMatchSheet(
        candidates: candidates,
        onAccept: onAccept,
        onReject: onReject,
        categoryLabelFor: categoryLabelFor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.bills.match.sheetTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.bills.match.sheetIntro,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: candidates.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _BillMatchGroup(
                    candidate: candidates[i],
                    onAccept: onAccept,
                    onReject: onReject,
                    categoryLabelFor: categoryLabelFor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One bill + its candidate transactions. Each candidate becomes a
/// side-by-side comparison block so the user can eyeball whether the
/// fields actually correspond.
class _BillMatchGroup extends StatelessWidget {
  const _BillMatchGroup({
    required this.candidate,
    required this.onAccept,
    required this.onReject,
    required this.categoryLabelFor,
  });

  final BillMatchCandidate candidate;
  final void Function(BillEntity bill, TransactionEntity tx) onAccept;
  final void Function(BillEntity bill, TransactionEntity tx) onReject;
  final CategoryLabelResolver categoryLabelFor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.bills.match.candidateQuestion,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        for (final tx in candidate.candidates) ...[
          _ComparisonCard(
            bill: candidate.bill,
            tx: tx,
            categoryLabelFor: categoryLabelFor,
            onAccept: () => onAccept(candidate.bill, tx),
            onReject: () => onReject(candidate.bill, tx),
          ),
          if (tx != candidate.candidates.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Side-by-side comparison of a bill and a candidate transaction —
/// description, category, amount, date for both. Action buttons sit at
/// the bottom of the card. The user can scan the four rows top to
/// bottom and decide if the pair matches.
class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.bill,
    required this.tx,
    required this.categoryLabelFor,
    required this.onAccept,
    required this.onReject,
  });

  final BillEntity bill;
  final TransactionEntity tx;
  final CategoryLabelResolver categoryLabelFor;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = bill.isPayable ? colors.expense : colors.income;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ComparisonColumn(
                  header: t.bills.match.billLabel,
                  description: bill.description,
                  category: categoryLabelFor(bill.categoryId),
                  amount: bill.amount,
                  date: bill.dueDate,
                  amountColor: accent,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 0.5,
                height: 96,
                color: colors.surfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ComparisonColumn(
                  header: t.bills.match.transactionLabel,
                  description: tx.description.trim().isEmpty
                      ? t.bills.match.fieldEmpty
                      : tx.description,
                  category: categoryLabelFor(tx.categoryId),
                  amount: tx.amount,
                  date: tx.date,
                  amountColor: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const FaIcon(FontAwesomeIcons.xmark, size: 12),
                  label: Text(t.bills.match.notThisOne),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onBackgroundLight,
                    side: BorderSide(color: colors.surfaceVariant),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAccept,
                  icon: const FaIcon(FontAwesomeIcons.check, size: 12),
                  label: Text(t.bills.match.yesItWas),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single side of the comparison — header pill + 4 labeled fields.
class _ComparisonColumn extends StatelessWidget {
  const _ComparisonColumn({
    required this.header,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.amountColor,
  });

  final String header;
  final String description;
  final String? category;
  final double amount;
  final DateTime date;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            header.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Field(
          label: t.bills.match.fieldDescription,
          value: description,
          color: colors.onBackground,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 6),
        _Field(
          label: t.bills.match.fieldCategory,
          value: category ?? t.bills.match.fieldEmpty,
          color: colors.onBackground,
        ),
        const SizedBox(height: 6),
        _Field(
          label: t.bills.match.fieldAmount,
          value: formatCurrency(amount),
          color: amountColor,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 6),
        _Field(
          label: t.bills.match.fieldDate,
          value: formatDate(date),
          color: colors.onBackground,
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.color,
    this.fontWeight = FontWeight.w500,
  });

  final String label;
  final String value;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: fontWeight,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
