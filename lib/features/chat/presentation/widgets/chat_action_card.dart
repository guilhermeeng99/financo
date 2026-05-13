import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/date_helpers.dart' as date_helpers;
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Lifecycle of an AI-proposed action as the user sees it. `pending` shows
/// Cancel/Confirm buttons; the resolved states replace those buttons with a
/// status badge so the user keeps the card as a record of what was decided.
enum ChatActionStatus { confirmed, cancelled }

/// Structured preview of an AI-suggested action. Renders below an AI bubble
/// whose `metadata.actionType` is set, replacing the previous "raw text +
/// inline Confirm button" pattern with a card the user can scan before
/// committing.
///
/// When `status` is non-null the card is in a settled state — the buttons
/// give way to a status badge so the confirmation/cancellation stays
/// visible in the conversation as a permanent record.
class ChatActionCard extends StatelessWidget {
  const ChatActionCard({
    required this.metadata,
    this.status,
    this.onConfirm,
    this.onCancel,
    super.key,
  });

  final Map<String, dynamic> metadata;
  final ChatActionStatus? status;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final preview = _ActionPreview.fromMetadata(context, metadata);

    return Padding(
      // Indent so the card aligns with the AI bubble (avatar width + gap).
      padding: const EdgeInsets.only(left: 40, bottom: 8, right: 4),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: preview.accent.withValues(alpha: 0.18),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(preview: preview),
            if (preview.amount != null) ...[
              const SizedBox(height: 12),
              Text(
                preview.amount!,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: preview.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (preview.headline != null) ...[
              const SizedBox(height: 2),
              Text(
                preview.headline!,
                style: context.textTheme.titleMedium?.copyWith(
                  color: colors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (preview.fields.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...preview.fields.map(
                (f) => _FieldRow(label: f.label, value: f.value),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (status == null)
              _PendingFooter(
                preview: preview,
                onConfirm: onConfirm!,
                onCancel: onCancel!,
              )
            else
              _StatusBadge(status: status!),
          ],
        ),
      ),
    );
  }
}

class _PendingFooter extends StatelessWidget {
  const _PendingFooter({
    required this.preview,
    required this.onConfirm,
    required this.onCancel,
  });

  final _ActionPreview preview;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: _CardSecondaryButton(
            label: t.chat.action.cancel,
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CardPrimaryButton(
            label: t.chat.action.confirm,
            color: preview.destructive ? colors.error : colors.primary,
            onPressed: onConfirm,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ChatActionStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isConfirmed = status == ChatActionStatus.confirmed;
    final accent = isConfirmed ? colors.success : colors.onBackgroundLight;
    final icon = isConfirmed
        ? FontAwesomeIcons.circleCheck
        : FontAwesomeIcons.circleXmark;
    final label = isConfirmed
        ? t.chat.action.statusConfirmed
        : t.chat.action.statusCancelled;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 14, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.preview});

  final _ActionPreview preview;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: preview.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(preview.icon, size: 14, color: preview.accent),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            preview.title,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.appColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPrimaryButton extends StatelessWidget {
  const _CardPrimaryButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 42),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.check, size: 14),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSecondaryButton extends StatelessWidget {
  const _CardSecondaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.onBackgroundLight,
          minimumSize: const Size(0, 42),
          padding: EdgeInsets.zero,
          side: BorderSide(color: colors.surfaceVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Internal model translating raw `metadata` into UI-ready fields. Centralizes
/// the per-action-type rendering decisions so [ChatActionCard] stays a thin
/// view.
class _ActionPreview {
  _ActionPreview({
    required this.title,
    required this.icon,
    required this.accent,
    this.amount,
    this.headline,
    this.fields = const [],
    this.destructive = false,
  });

  factory _ActionPreview.fromMetadata(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final actionType = meta['actionType'] as String?;
    final action = meta['action'] as String?;
    return switch (actionType) {
      'transaction' => _ActionPreview.transaction(context, meta),
      'transfer' => _ActionPreview.transfer(context, meta),
      'account' => action == 'delete'
          ? _ActionPreview.accountDelete(context, meta)
          : _ActionPreview.accountCreate(context, meta),
      'category' => action == 'delete'
          ? _ActionPreview.categoryDelete(context, meta)
          : _ActionPreview.categoryCreate(context, meta),
      'bill' => switch (action) {
        'markPaid' => _ActionPreview.billMarkPaid(context, meta),
        'delete' => _ActionPreview.billDelete(context, meta),
        'update' => _ActionPreview.billUpdate(context, meta),
        _ => _ActionPreview.billCreate(context, meta),
      },
      'budget' => switch (action) {
        'delete' => _ActionPreview.budgetDelete(context, meta),
        'update' => _ActionPreview.budgetUpdate(context, meta),
        _ => _ActionPreview.budgetCreate(context, meta),
      },
      _ => _ActionPreview(
        title: actionType ?? 'Action',
        icon: FontAwesomeIcons.bolt,
        accent: context.appColors.primary,
      ),
    };
  }

  factory _ActionPreview.transaction(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final colors = context.appColors;
    final isIncome = (meta['type'] as String?) == 'income';
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    return _ActionPreview(
      title: isIncome
          ? t.chat.action.transactionIncome
          : t.chat.action.transactionExpense,
      icon: isIncome
          ? FontAwesomeIcons.arrowDown
          : FontAwesomeIcons.arrowUp,
      accent: isIncome ? colors.income : colors.expense,
      amount: formatCurrency(amount),
      headline: meta['description'] as String?,
      fields: [
        if (meta['category'] != null)
          (label: t.chat.action.fieldCategory, value: '${meta['category']}'),
        if (meta['account'] != null)
          (label: t.chat.action.fieldAccount, value: '${meta['account']}'),
        (
          label: t.chat.action.fieldDate,
          value: _formatDate(meta['date'] as String?),
        ),
      ],
    );
  }

  factory _ActionPreview.transfer(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final colors = context.appColors;
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    return _ActionPreview(
      title: t.chat.action.transfer,
      icon: FontAwesomeIcons.rightLeft,
      accent: colors.primary,
      amount: formatCurrency(amount),
      headline: meta['description'] as String?,
      fields: [
        if (meta['from'] != null)
          (label: t.chat.action.fieldFromAccount, value: '${meta['from']}'),
        if (meta['to'] != null)
          (label: t.chat.action.fieldToAccount, value: '${meta['to']}'),
        (
          label: t.chat.action.fieldDate,
          value: _formatDate(meta['date'] as String?),
        ),
      ],
    );
  }

  factory _ActionPreview.accountCreate(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final colors = context.appColors;
    final isCreditCard = (meta['type'] as String?) == 'creditCard';
    final balance = (meta['balance'] as num?)?.toDouble();
    final creditLimit = (meta['creditLimit'] as num?)?.toDouble();
    return _ActionPreview(
      title: t.chat.action.accountCreate,
      icon: isCreditCard
          ? FontAwesomeIcons.creditCard
          : FontAwesomeIcons.buildingColumns,
      accent: colors.primary,
      headline: meta['name'] as String?,
      fields: [
        if (meta['bank'] != null)
          (label: t.chat.action.fieldBank, value: '${meta['bank']}'),
        (
          label: t.chat.action.fieldType,
          value: isCreditCard ? 'Credit card' : 'Checking',
        ),
        if (balance != null && balance != 0)
          (label: t.chat.action.fieldBalance, value: formatCurrency(balance)),
        if (creditLimit != null)
          (
            label: t.chat.action.fieldCreditLimit,
            value: formatCurrency(creditLimit),
          ),
        if (meta['closingDay'] != null)
          (
            label: t.chat.action.fieldClosingDay,
            value: '${meta['closingDay']}',
          ),
        if (meta['dueDay'] != null)
          (label: t.chat.action.fieldDueDay, value: '${meta['dueDay']}'),
        if (meta['linkedAccountName'] != null)
          (
            label: t.chat.action.fieldLinkedAccount,
            value: '${meta['linkedAccountName']}',
          ),
      ],
    );
  }

  factory _ActionPreview.accountDelete(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    return _ActionPreview(
      title: t.chat.action.accountDelete,
      icon: FontAwesomeIcons.trash,
      accent: context.appColors.error,
      headline: meta['name'] as String?,
      destructive: true,
    );
  }

  factory _ActionPreview.categoryCreate(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final isIncome = (meta['type'] as String?) == 'income';
    return _ActionPreview(
      title: t.chat.action.categoryCreate,
      icon: FontAwesomeIcons.tag,
      accent: isIncome
          ? context.appColors.income
          : context.appColors.primary,
      headline: meta['name'] as String?,
      fields: [
        (
          label: t.chat.action.fieldType,
          value: isIncome ? 'Income' : 'Expense',
        ),
      ],
    );
  }

  factory _ActionPreview.categoryDelete(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    return _ActionPreview(
      title: t.chat.action.categoryDelete,
      icon: FontAwesomeIcons.trash,
      accent: context.appColors.error,
      headline: meta['name'] as String?,
      destructive: true,
    );
  }

  factory _ActionPreview.billCreate(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final colors = context.appColors;
    final isReceivable = (meta['type'] as String?) == 'receivable';
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    final isMonthly = (meta['recurrence'] as String?) == 'monthly';
    return _ActionPreview(
      title: t.chat.action.billCreate,
      icon: FontAwesomeIcons.calendar,
      accent: isReceivable ? colors.income : colors.warning,
      amount: formatCurrency(amount),
      headline: meta['description'] as String?,
      fields: [
        (
          label: t.chat.action.fieldDueDate,
          value: _formatDate(meta['dueDate'] as String?),
        ),
        (
          label: t.chat.action.fieldRecurrence,
          value: isMonthly ? 'Monthly' : 'One-time',
        ),
        if (meta['category'] != null)
          (label: t.chat.action.fieldCategory, value: '${meta['category']}'),
        if (meta['notes'] != null && (meta['notes'] as String).isNotEmpty)
          (label: t.chat.action.fieldNotes, value: '${meta['notes']}'),
      ],
    );
  }

  factory _ActionPreview.billUpdate(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final amount = (meta['amount'] as num?)?.toDouble();
    return _ActionPreview(
      title: t.chat.action.billUpdate,
      icon: FontAwesomeIcons.penToSquare,
      accent: context.appColors.primary,
      amount: amount != null ? formatCurrency(amount) : null,
      headline: meta['description'] as String?,
      fields: [
        if (meta['dueDate'] != null)
          (
            label: t.chat.action.fieldDueDate,
            value: _formatDate(meta['dueDate'] as String?),
          ),
        if (meta['notes'] != null && (meta['notes'] as String).isNotEmpty)
          (label: t.chat.action.fieldNotes, value: '${meta['notes']}'),
      ],
    );
  }

  factory _ActionPreview.billMarkPaid(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    return _ActionPreview(
      title: t.chat.action.billMarkPaid,
      icon: FontAwesomeIcons.circleCheck,
      accent: context.appColors.success,
      headline: meta['description'] as String?,
      fields: [
        if (meta['accountName'] != null)
          (
            label: t.chat.action.fieldAccount,
            value: '${meta['accountName']}',
          ),
      ],
    );
  }

  factory _ActionPreview.billDelete(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    return _ActionPreview(
      title: t.chat.action.billDelete,
      icon: FontAwesomeIcons.trash,
      accent: context.appColors.error,
      headline: meta['description'] as String?,
      destructive: true,
    );
  }

  factory _ActionPreview.budgetCreate(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    return _ActionPreview(
      title: t.chat.action.budgetCreate,
      icon: FontAwesomeIcons.bullseye,
      accent: context.appColors.primary,
      amount: formatCurrency(amount),
      headline: meta['category'] as String?,
      fields: [
        (label: t.chat.action.fieldCategory, value: '${meta['category']}'),
      ],
    );
  }

  factory _ActionPreview.budgetUpdate(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    final amount = (meta['amount'] as num?)?.toDouble();
    return _ActionPreview(
      title: t.chat.action.budgetUpdate,
      icon: FontAwesomeIcons.penToSquare,
      accent: context.appColors.primary,
      amount: amount != null ? formatCurrency(amount) : null,
      headline: meta['category'] as String?,
      fields: [
        (label: t.chat.action.fieldCategory, value: '${meta['category']}'),
      ],
    );
  }

  factory _ActionPreview.budgetDelete(
    BuildContext context,
    Map<String, dynamic> meta,
  ) {
    return _ActionPreview(
      title: t.chat.action.budgetDelete,
      icon: FontAwesomeIcons.trash,
      accent: context.appColors.error,
      headline: meta['category'] as String?,
      destructive: true,
    );
  }

  final String title;
  final FaIconData icon;
  final Color accent;
  final String? amount;
  final String? headline;
  final List<({String label, String value})> fields;
  final bool destructive;

  static String _formatDate(String? raw) {
    if (raw == null) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return date_helpers.formatDate(parsed);
  }
}
