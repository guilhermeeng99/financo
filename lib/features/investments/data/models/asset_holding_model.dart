import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';

class AssetHoldingModel extends AssetHoldingEntity {
  const AssetHoldingModel({
    required super.id,
    required super.userId,
    required super.accountId,
    required super.assetClassId,
    required super.amount,
    required super.updatedAt,
    super.notes,
  });

  factory AssetHoldingModel.fromFirestore(DocumentSnapshot doc) {
    return AssetHoldingModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory AssetHoldingModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final updatedAtRaw = data['updatedAt'];
    return AssetHoldingModel(
      id: id,
      userId: data['userId'] as String,
      accountId: data['accountId'] as String,
      assetClassId: data['assetClassId'] as String,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      notes: data['notes'] as String?,
      updatedAt: updatedAtRaw is Timestamp
          ? updatedAtRaw.toDate()
          : DateTime.tryParse(updatedAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory AssetHoldingModel.fromEntity(AssetHoldingEntity entity) {
    return AssetHoldingModel(
      id: entity.id,
      userId: entity.userId,
      accountId: entity.accountId,
      assetClassId: entity.assetClassId,
      amount: entity.amount,
      notes: entity.notes,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accountId': accountId,
      'assetClassId': assetClassId,
      'amount': amount,
      if (notes != null) 'notes': notes,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
