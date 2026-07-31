import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/enum_parse.dart';
import 'package:financo/features/investing/domain/entities/snapshot.dart';

class SnapshotModel extends Snapshot {
  const SnapshotModel({
    required super.userId,
    required super.date,
    required super.totalValue,
    required super.totalInvested,
    required super.unrealizedPL,
  });

  factory SnapshotModel.fromFirestore(DocumentSnapshot doc) {
    return SnapshotModel.fromMap(data: doc.data()! as Map<String, dynamic>);
  }

  factory SnapshotModel.fromMap({required Map<String, dynamic> data}) {
    final currency = enumByName(
      Currency.values,
      data['currency'],
      Currency.brl,
    );
    final dateRaw = data['date'];
    return SnapshotModel(
      userId: data['userId'] as String,
      date: dateRaw is Timestamp
          ? dateRaw.toDate()
          : DateTime.tryParse(dateRaw?.toString() ?? '') ?? DateTime.now(),
      totalValue: Money((data['totalValueMinor'] as num).toInt(), currency),
      totalInvested: Money(
        (data['totalInvestedMinor'] as num).toInt(),
        currency,
      ),
      unrealizedPL: Money((data['unrealizedPlMinor'] as num).toInt(), currency),
    );
  }

  factory SnapshotModel.fromEntity(Snapshot e) {
    return SnapshotModel(
      userId: e.userId,
      date: e.date,
      totalValue: e.totalValue,
      totalInvested: e.totalInvested,
      unrealizedPL: e.unrealizedPL,
    );
  }

  /// The deterministic doc id — one per user per day, so re-recording a day
  /// overwrites instead of appending. See `docs/specs/valuation.md`.
  String get docId => '${userId}_$dayKey';

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'dayKey': dayKey,
      'totalValueMinor': totalValue.minorUnits,
      'totalInvestedMinor': totalInvested.minorUnits,
      'unrealizedPlMinor': unrealizedPL.minorUnits,
      'currency': totalValue.currency.name,
    };
  }
}
