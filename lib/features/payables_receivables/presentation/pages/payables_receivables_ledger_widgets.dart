part of 'payables_receivables_page.dart';

class _LedgerToggle extends StatelessWidget {
  const _LedgerToggle(this.view, this.onChanged, this.availableViews);

  final PayablesReceivablesView view;
  final ValueChanged<PayablesReceivablesView> onChanged;
  final List<PayablesReceivablesView> availableViews;

  @override
  Widget build(BuildContext context) {
    return FinancoPillToggle<PayablesReceivablesView>(
      selected: view,
      onChanged: onChanged,
      options: _allOptions
          .where((option) => availableViews.contains(option.value))
          .toList(),
    );
  }

  List<FinancoPillToggleOption<PayablesReceivablesView>> get _allOptions {
    return [
      FinancoPillToggleOption(
        value: PayablesReceivablesView.payables,
        label: t.payablesReceivables.typePayable,
        icon: FontAwesomeIcons.arrowUp,
      ),
      FinancoPillToggleOption(
        value: PayablesReceivablesView.receivables,
        label: t.payablesReceivables.typeReceivable,
        icon: FontAwesomeIcons.arrowDown,
      ),
      FinancoPillToggleOption(
        value: PayablesReceivablesView.paid,
        label: t.payablesReceivables.paidPlural,
        icon: FontAwesomeIcons.circleCheck,
      ),
      FinancoPillToggleOption(
        value: PayablesReceivablesView.received,
        label: t.payablesReceivables.receivedPlural,
        icon: FontAwesomeIcons.handHoldingDollar,
      ),
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.view});

  final _PayablesReceivablesSummary summary;
  final PayablesReceivablesView view;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                label: _isSettledModeForView(view)
                    ? t.payablesReceivables.paid
                    : t.payablesReceivables.typePayable,
                value: _isSettledModeForView(view)
                    ? summary.paid
                    : summary.toPay,
                color: colors.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryMetric(
                label: _isSettledModeForView(view)
                    ? t.payablesReceivables.received
                    : t.payablesReceivables.typeReceivable,
                value: _isSettledModeForView(view)
                    ? summary.received
                    : summary.toReceive,
                color: colors.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.onBackgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatCurrency(value),
            style: context.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionSection extends StatelessWidget {
  const _TransactionSection({
    required this.section,
    required this.view,
    required this.onOpen,
    required this.onSettle,
    required this.onDelete,
  });

  final _TransactionSectionData section;
  final PayablesReceivablesView view;
  final void Function(TransactionEntity) onOpen;
  final void Function(TransactionEntity) onSettle;
  final void Function(TransactionEntity) onDelete;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          FinancoSectionHeader(
            title: section.title,
            count: section.transactions.length,
            accent: section.color(context),
          ),
          ...section.transactions.map(
            (transaction) => _DismissibleTransactionTile(
              transaction: transaction,
              view: view,
              onOpen: () => onOpen(transaction),
              onSettle: () => onSettle(transaction),
              onDelete: () => onDelete(transaction),
            ),
          ),
        ]),
      ),
    );
  }
}

class _DismissibleTransactionTile extends StatelessWidget {
  const _DismissibleTransactionTile({
    required this.transaction,
    required this.view,
    required this.onOpen,
    required this.onSettle,
    required this.onDelete,
  });

  final TransactionEntity transaction;
  final PayablesReceivablesView view;
  final VoidCallback onOpen;
  final VoidCallback onSettle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: context.appColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const FaIcon(FontAwesomeIcons.trash, color: Colors.white),
      ),
      child: _TransactionTile(
        transaction: transaction,
        view: view,
        onOpen: onOpen,
        onSettle: onSettle,
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.view,
    required this.onOpen,
    required this.onSettle,
  });

  final TransactionEntity transaction;
  final PayablesReceivablesView view;
  final VoidCallback onOpen;
  final VoidCallback onSettle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final amountAccent = transaction.isReceivable
        ? colors.income
        : colors.expense;
    final statusAccent = _statusAccent(context, transaction);
    final category = _categoryLabel(context, transaction.categoryId);
    final isPendingView =
        view == PayablesReceivablesView.payables ||
        view == PayablesReceivablesView.receivables;
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
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatusDisc(transaction: transaction, color: statusAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description.isEmpty
                            ? t.transactions.transaction
                            : transaction.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(transaction, category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: transaction.isOverdue
                              ? colors.expense
                              : colors.onBackgroundLight,
                          fontWeight: transaction.isOverdue
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _Amount(transaction: transaction),
                if (isPendingView) ...[
                  const SizedBox(width: 8),
                  _SettleButton(
                    transaction: transaction,
                    color: amountAccent,
                    onPressed: onSettle,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle(TransactionEntity transaction, String? category) {
    final parts = <String>[
      formatDayMonth(
        transaction.isPending ? transaction.dueDate : transaction.date,
      ),
    ];
    if (category != null && category.isNotEmpty) parts.add(category);
    if (transaction.isPending) {
      if (transaction.isOverdue) {
        parts.add(t.payablesReceivables.overdue);
      } else if (transaction.isDueToday) {
        parts.add(t.payablesReceivables.dueToday);
      } else {
        parts.add(t.payablesReceivables.scheduled);
      }
    } else {
      parts.add(
        transaction.isReceivable
            ? t.payablesReceivables.received
            : t.payablesReceivables.paid,
      );
    }
    return parts.join(' Â· ');
  }

  String? _categoryLabel(BuildContext context, String categoryId) {
    if (categoryId.isEmpty) return null;
    final categories = context.read<CategoriesCubit>().state.categoriesOrEmpty;
    final category = categories.where((c) => c.id == categoryId).firstOrNull;
    return category?.displayPath(categories);
  }
}

class _StatusDisc extends StatelessWidget {
  const _StatusDisc({required this.transaction, required this.color});

  final TransactionEntity transaction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = transaction.isPaid
        ? FontAwesomeIcons.circleCheck
        : transaction.isOverdue
        ? FontAwesomeIcons.triangleExclamation
        : FontAwesomeIcons.clock;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: FaIcon(icon, size: 17, color: color)),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isReceivable
        ? context.appColors.income
        : context.appColors.expense;
    final prefix = transaction.isReceivable ? '+' : '-';
    return Text(
      '$prefix${formatCurrency(transaction.amount)}',
      style: context.textTheme.titleSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SettleButton extends StatelessWidget {
  const _SettleButton({
    required this.transaction,
    required this.color,
    required this.onPressed,
  });

  final TransactionEntity transaction;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: transaction.isReceivable
          ? t.payablesReceivables.markAsReceived
          : t.payablesReceivables.markAsPaid,
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

class _EmptyLedger extends StatelessWidget {
  const _EmptyLedger({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.surfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.calendarCheck,
                        size: 24,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.payablesReceivables.emptyTitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.payablesReceivables.empty,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackgroundLight,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    label: Text(t.transactions.addTransaction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
