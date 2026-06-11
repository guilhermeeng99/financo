part of 'payables_receivables_page.dart';

class _PayablesReceivablesSnapshot {
  const _PayablesReceivablesSnapshot({
    required this.month,
    required this.transactions,
  });

  final DateTime month;
  final List<TransactionEntity> transactions;

  List<TransactionEntity> visibleFor(PayablesReceivablesView view) {
    final start = startOfMonth(month);
    final end = endOfMonth(month);
    final visible = transactions.where((tx) {
      return switch (view) {
        PayablesReceivablesView.payables =>
          tx.isPending && tx.isPayable && _inRange(tx.dueDate, start, end),
        PayablesReceivablesView.receivables =>
          tx.isPending && tx.isReceivable && _inRange(tx.dueDate, start, end),
        PayablesReceivablesView.paid =>
          tx.isPaid && tx.isPayable && _inRange(tx.date, start, end),
        PayablesReceivablesView.received =>
          tx.isPaid && tx.isReceivable && _inRange(tx.date, start, end),
      };
    }).toList();

    return visible..sort((a, b) {
      final dateA = a.isPending ? a.dueDate : a.date;
      final dateB = b.isPending ? b.dueDate : b.date;
      return a.isPending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }
}

class _PayablesReceivablesSummary {
  const _PayablesReceivablesSummary({
    required this.toPay,
    required this.toReceive,
    required this.paid,
    required this.received,
  });

  factory _PayablesReceivablesSummary.from(
    List<TransactionEntity> payables,
    List<TransactionEntity> receivables,
    List<TransactionEntity> paid,
    List<TransactionEntity> received,
  ) {
    return _PayablesReceivablesSummary(
      toPay: payables.fold<double>(0, (sum, tx) => sum + tx.amount),
      toReceive: receivables.fold<double>(0, (sum, tx) => sum + tx.amount),
      paid: paid.fold<double>(0, (sum, tx) => sum + tx.amount),
      received: received.fold<double>(0, (sum, tx) => sum + tx.amount),
    );
  }

  final double toPay;
  final double toReceive;
  final double paid;
  final double received;
}

class _TransactionGroups {
  const _TransactionGroups(this.sections);

  factory _TransactionGroups.from(
    List<TransactionEntity> transactions,
    PayablesReceivablesView view,
  ) {
    if (view == PayablesReceivablesView.paid ||
        view == PayablesReceivablesView.received) {
      return _TransactionGroups(
        [
          _TransactionSectionData(
            title: view == PayablesReceivablesView.paid
                ? t.payablesReceivables.paidPlural
                : t.payablesReceivables.receivedPlural,
            transactions: transactions,
            color: (context) => context.appColors.onBackgroundLight,
          ),
        ].where((section) => section.transactions.isNotEmpty).toList(),
      );
    }

    final overdue = <TransactionEntity>[];
    final today = <TransactionEntity>[];
    final upcoming = <TransactionEntity>[];
    for (final tx in transactions) {
      if (tx.isOverdue) {
        overdue.add(tx);
      } else if (tx.isDueToday) {
        today.add(tx);
      } else {
        upcoming.add(tx);
      }
    }

    return _TransactionGroups(
      [
        _TransactionSectionData(
          title: t.payablesReceivables.overdueGroup,
          transactions: overdue,
          color: (context) => context.appColors.expense,
        ),
        _TransactionSectionData(
          title: t.payablesReceivables.todayGroup,
          transactions: today,
          color: (context) => context.appColors.warning,
        ),
        _TransactionSectionData(
          title: t.payablesReceivables.upcomingGroup,
          transactions: upcoming,
          color: (context) => context.appColors.warning,
        ),
      ].where((section) => section.transactions.isNotEmpty).toList(),
    );
  }

  final List<_TransactionSectionData> sections;

  bool get isEmpty => sections.isEmpty;
}

class _TransactionSectionData {
  const _TransactionSectionData({
    required this.title,
    required this.transactions,
    required this.color,
  });

  final String title;
  final List<TransactionEntity> transactions;
  final Color Function(BuildContext context) color;
}

class _SnapshotLoadException implements Exception {
  const _SnapshotLoadException(this.failure);

  final Failure failure;
}

bool _inRange(DateTime date, DateTime start, DateTime end) =>
    !date.isBefore(start) && !date.isAfter(end);

bool _isSettledMode(List<PayablesReceivablesView> views) {
  return views.every(_isSettledModeForView);
}

bool _isSettledModeForView(PayablesReceivablesView view) {
  return view == PayablesReceivablesView.paid ||
      view == PayablesReceivablesView.received;
}

Color _statusAccent(BuildContext context, TransactionEntity transaction) {
  final colors = context.appColors;
  if (transaction.isPaid) {
    return transaction.isReceivable ? colors.income : colors.expense;
  }
  if (transaction.isOverdue) return colors.expense;
  return colors.warning;
}
