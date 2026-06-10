import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

const int kMaxRecurringWindowMonths = 12;
const int kMaxInstallmentCount = 12;

List<TransactionEntity> buildRecurringTransactions({
  required TransactionEntity template,
  required DateTime now,
  required int installmentCount,
}) {
  switch (template.recurrence) {
    case TransactionRecurrence.single:
      return [template];
    case TransactionRecurrence.installment:
      return _buildInstallments(
        template: template,
        now: now,
        installmentCount: installmentCount,
      );
    case TransactionRecurrence.fixed:
      return _buildFixedWindow(template: template, now: now);
  }
}

List<TransactionEntity> buildMissingFixedOccurrences({
  required TransactionEntity latest,
  required DateTime now,
}) {
  if (latest.recurrence != TransactionRecurrence.fixed) return [];
  final windowEnd = addMonthsClamped(now, kMaxRecurringWindowMonths);
  final endDate = latest.recurrenceEndDate;
  final targetEnd = endDate != null && endDate.isBefore(windowEnd)
      ? endDate
      : windowEnd;

  final generated = <TransactionEntity>[];
  var previous = latest;
  final interval = _safeInterval(latest.recurrenceIntervalMonths);
  while (true) {
    final nextDate = addMonthsClamped(
      previous.dueDate,
      interval,
    );
    if (nextDate.isAfter(targetEnd)) break;
    if (endDate != null && !nextDate.isBefore(endDate)) break;
    final nextIndex = (previous.recurrenceIndex ?? 1) + 1;
    generated.add(
      TransactionEntity(
        id: '',
        userId: previous.userId,
        accountId: previous.accountId,
        categoryId: previous.categoryId,
        type: previous.type,
        amount: previous.amount,
        description: previous.description,
        date: nextDate,
        settlementStatus: TransactionSettlementStatus.pending,
        dueDate: nextDate,
        recurrence: previous.recurrence,
        recurrenceGroupId: previous.recurrenceGroupId,
        recurrenceIntervalMonths: previous.recurrenceIntervalMonths,
        recurrenceIndex: nextIndex,
        recurrenceTotal: previous.recurrenceTotal,
        recurrenceBaseDescription: previous.recurrenceBaseDescription,
        recurrenceEndDate: previous.recurrenceEndDate,
        notes: previous.notes,
        linkedTransactionId: previous.linkedTransactionId,
        createdAt: now,
        updatedAt: now,
      ),
    );
    previous = generated.last;
  }
  return generated;
}

String installmentDescription({
  required String baseDescription,
  required int index,
  required int total,
}) {
  final trimmed = baseDescription.trim();
  final suffix = '$index/$total';
  if (trimmed.isEmpty) return suffix;
  return '$trimmed $suffix';
}

int maxInstallmentsForInterval(int intervalMonths) {
  final maxByWindow =
      (kMaxRecurringWindowMonths ~/ _safeInterval(intervalMonths)) + 1;
  return maxByWindow < kMaxInstallmentCount
      ? maxByWindow
      : kMaxInstallmentCount;
}

DateTime addMonthsClamped(DateTime date, int months) {
  final targetMonth = date.month + months;
  final target = DateTime(date.year, targetMonth);
  final lastDay = DateTime(target.year, target.month + 1, 0).day;
  final day = date.day > lastDay ? lastDay : date.day;
  return DateTime(
    target.year,
    target.month,
    day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

List<TransactionEntity> _buildInstallments({
  required TransactionEntity template,
  required DateTime now,
  required int installmentCount,
}) {
  final interval = _safeInterval(template.recurrenceIntervalMonths);
  final total = _clampInt(
    installmentCount,
    1,
    maxInstallmentsForInterval(interval),
  );
  final amounts = _splitAmount(template.amount, total);
  final groupId = template.recurrenceGroupId ?? _newGroupId(now);
  final baseDescription =
      template.recurrenceBaseDescription ?? template.description;

  return [
    for (var i = 0; i < total; i++)
      _occurrenceFromTemplate(
        template,
        id: i == 0 ? template.id : '',
        groupId: groupId,
        amount: amounts[i],
        date: addMonthsClamped(
          template.date,
          i * interval,
        ),
        recurrenceIndex: i + 1,
        recurrenceTotal: total,
        description: installmentDescription(
          baseDescription: baseDescription,
          index: i + 1,
          total: total,
        ),
        baseDescription: baseDescription,
        now: now,
      ),
  ];
}

List<TransactionEntity> _buildFixedWindow({
  required TransactionEntity template,
  required DateTime now,
}) {
  final groupId = template.recurrenceGroupId ?? _newGroupId(now);
  final occurrences = <TransactionEntity>[];
  final interval = _safeInterval(template.recurrenceIntervalMonths);
  for (
    var monthOffset = 0;
    monthOffset <= kMaxRecurringWindowMonths;
    monthOffset += interval
  ) {
    occurrences.add(
      _occurrenceFromTemplate(
        template,
        id: monthOffset == 0 ? template.id : '',
        groupId: groupId,
        amount: template.amount,
        date: addMonthsClamped(template.date, monthOffset),
        recurrenceIndex: (monthOffset ~/ interval) + 1,
        description: template.description,
        baseDescription:
            template.recurrenceBaseDescription ?? template.description,
        now: now,
      ),
    );
  }
  return occurrences;
}

TransactionEntity _occurrenceFromTemplate(
  TransactionEntity template, {
  required String id,
  required String groupId,
  required double amount,
  required DateTime date,
  required int recurrenceIndex,
  required String description,
  required String baseDescription,
  required DateTime now,
  int? recurrenceTotal,
}) {
  final isFirst = recurrenceIndex == 1;
  final settlementStatus = isFirst
      ? template.settlementStatus
      : TransactionSettlementStatus.pending;
  return TransactionEntity(
    id: id,
    userId: template.userId,
    accountId: template.accountId,
    categoryId: template.categoryId,
    type: template.type,
    amount: amount,
    description: description,
    date: date,
    settlementStatus: settlementStatus,
    dueDate: date,
    settledAt: settlementStatus == TransactionSettlementStatus.paid
        ? date
        : null,
    recurrence: template.recurrence,
    recurrenceGroupId: groupId,
    recurrenceIntervalMonths: template.recurrenceIntervalMonths,
    recurrenceIndex: recurrenceIndex,
    recurrenceTotal: recurrenceTotal,
    recurrenceBaseDescription: baseDescription,
    recurrenceEndDate: template.recurrenceEndDate,
    notes: template.notes,
    linkedTransactionId: template.linkedTransactionId,
    createdAt: isFirst ? template.createdAt : now,
    updatedAt: now,
  );
}

List<double> _splitAmount(double amount, int count) {
  final totalCents = (amount * 100).round();
  final base = totalCents ~/ count;
  final remainder = totalCents % count;
  return [
    for (var i = 0; i < count; i++) (base + (i < remainder ? 1 : 0)) / 100,
  ];
}

int _safeInterval(int value) => _clampInt(value, 1, kMaxRecurringWindowMonths);

int _clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

String _newGroupId(DateTime now) => 'rec-${now.microsecondsSinceEpoch}';
