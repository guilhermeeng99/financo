import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.accountId,
    required super.categoryId,
    required super.type,
    required super.amount,
    required super.description,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    super.settlementStatus,
    super.dueDate,
    super.settledAt,
    super.recurrence,
    super.recurrenceGroupId,
    super.recurrenceIntervalMonths,
    super.recurrenceIndex,
    super.recurrenceTotal,
    super.recurrenceBaseDescription,
    super.recurrenceEndDate,
    super.notes,
    super.linkedTransactionId,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    return TransactionModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory TransactionModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return TransactionModel(
      id: id,
      userId: data['userId'] as String,
      accountId: data['accountId'] as String,
      categoryId: data['categoryId'] as String,
      type: TransactionType.values.byName(data['type'] as String),
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] as String,
      date: (data['date'] as Timestamp).toDate(),
      settlementStatus: _parseSettlementStatus(data['settlementStatus']),
      dueDate:
          _readDate(data['dueDate']) ?? (data['date'] as Timestamp).toDate(),
      settledAt: _readDate(data['settledAt']),
      recurrence: _parseRecurrence(data['recurrence']),
      recurrenceGroupId: data['recurrenceGroupId'] as String?,
      recurrenceIntervalMonths:
          (data['recurrenceIntervalMonths'] as num?)?.toInt() ?? 1,
      recurrenceIndex: (data['recurrenceIndex'] as num?)?.toInt(),
      recurrenceTotal: (data['recurrenceTotal'] as num?)?.toInt(),
      recurrenceBaseDescription: data['recurrenceBaseDescription'] as String?,
      recurrenceEndDate: _readDate(data['recurrenceEndDate']),
      notes: data['notes'] as String?,
      linkedTransactionId: data['linkedTransactionId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      accountId: entity.accountId,
      categoryId: entity.categoryId,
      type: entity.type,
      amount: entity.amount,
      description: entity.description,
      date: entity.date,
      settlementStatus: entity.settlementStatus,
      dueDate: entity.dueDate,
      settledAt: entity.settledAt,
      recurrence: entity.recurrence,
      recurrenceGroupId: entity.recurrenceGroupId,
      recurrenceIntervalMonths: entity.recurrenceIntervalMonths,
      recurrenceIndex: entity.recurrenceIndex,
      recurrenceTotal: entity.recurrenceTotal,
      recurrenceBaseDescription: entity.recurrenceBaseDescription,
      recurrenceEndDate: entity.recurrenceEndDate,
      notes: entity.notes,
      linkedTransactionId: entity.linkedTransactionId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accountId': accountId,
      'categoryId': categoryId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'settlementStatus': settlementStatus.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'settledAt': settledAt == null ? null : Timestamp.fromDate(settledAt!),
      'recurrence': recurrence.name,
      'recurrenceGroupId': recurrenceGroupId,
      'recurrenceIntervalMonths': recurrenceIntervalMonths,
      'recurrenceIndex': recurrenceIndex,
      'recurrenceTotal': recurrenceTotal,
      'recurrenceBaseDescription': recurrenceBaseDescription,
      'recurrenceEndDate': recurrenceEndDate == null
          ? null
          : Timestamp.fromDate(recurrenceEndDate!),
      'notes': notes,
      'linkedTransactionId': linkedTransactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

DateTime? _readDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

TransactionSettlementStatus _parseSettlementStatus(Object? value) {
  if (value is! String) return TransactionSettlementStatus.paid;
  return TransactionSettlementStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => TransactionSettlementStatus.paid,
  );
}

TransactionRecurrence _parseRecurrence(Object? value) {
  if (value == 'oneShot') return TransactionRecurrence.single;
  if (value == 'monthly') return TransactionRecurrence.fixed;
  if (value is! String) return TransactionRecurrence.single;
  return TransactionRecurrence.values.firstWhere(
    (recurrence) => recurrence.name == value,
    orElse: () => TransactionRecurrence.single,
  );
}
