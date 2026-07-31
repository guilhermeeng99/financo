import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/enum_parse.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';

class AssetTransactionModel extends AssetTransaction {
  const AssetTransactionModel({
    required super.id,
    required super.userId,
    required super.institutionId,
    required super.assetId,
    required super.kind,
    required super.quantity,
    required super.unitPrice,
    required super.fees,
    required super.amount,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
    super.fundingAccountId,
    super.cashAmount,
  });

  factory AssetTransactionModel.fromFirestore(DocumentSnapshot doc) {
    return AssetTransactionModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory AssetTransactionModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final ccy = enumByName(Currency.values, data['currency'], Currency.brl);
    return AssetTransactionModel(
      id: id,
      userId: data['userId'] as String,
      institutionId: data['institutionId'] as String,
      assetId: data['assetId'] as String,
      kind: enumByName(
        TransactionKind.values,
        data['kind'],
        TransactionKind.buy,
      ),
      quantity: (data['quantity'] as num).toDouble(),
      unitPrice: Money((data['unitPriceMinor'] as num).toInt(), ccy),
      fees: Money((data['feesMinor'] as num).toInt(), ccy),
      amount: Money((data['amountMinor'] as num).toInt(), ccy),
      date: _toDate(data['date']),
      notes: data['notes'] as String?,
      fundingAccountId: data['fundingAccountId'] as String?,
      cashAmount: data['cashAmountMinor'] == null
          ? null
          : Money((data['cashAmountMinor'] as num).toInt(), Currency.brl),
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  factory AssetTransactionModel.fromEntity(AssetTransaction e) {
    return AssetTransactionModel(
      id: e.id,
      userId: e.userId,
      institutionId: e.institutionId,
      assetId: e.assetId,
      kind: e.kind,
      quantity: e.quantity,
      unitPrice: e.unitPrice,
      fees: e.fees,
      amount: e.amount,
      date: e.date,
      notes: e.notes,
      fundingAccountId: e.fundingAccountId,
      cashAmount: e.cashAmount,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  static DateTime _toDate(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    return DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'institutionId': institutionId,
      'assetId': assetId,
      'kind': kind.name,
      'quantity': quantity,
      'unitPriceMinor': unitPrice.minorUnits,
      'feesMinor': fees.minorUnits,
      'amountMinor': amount.minorUnits,
      'currency': amount.currency.name,
      'date': Timestamp.fromDate(date),
      if (notes != null) 'notes': notes,
      if (fundingAccountId != null) 'fundingAccountId': fundingAccountId,
      if (cashAmount != null) 'cashAmountMinor': cashAmount!.minorUnits,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
