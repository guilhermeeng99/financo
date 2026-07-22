import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/investing/domain/entities/asset.dart';

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.userId,
    required super.ticker,
    required super.name,
    required super.kind,
    required super.market,
    required super.currency,
    required super.createdAt,
    super.institutionId,
    super.metadata,
  });

  factory AssetModel.fromFirestore(DocumentSnapshot doc) {
    return AssetModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory AssetModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final createdAtRaw = data['createdAt'];
    final rawMeta = data['metadata'] as Map<String, dynamic>? ?? const {};
    return AssetModel(
      id: id,
      userId: data['userId'] as String,
      ticker: data['ticker'] as String,
      name: data['name'] as String,
      kind: AssetKind.values.byName(data['kind'] as String),
      market: Market.values.byName(data['market'] as String),
      currency: Currency.values.byName(data['currency'] as String),
      institutionId: data['institutionId'] as String?,
      metadata: rawMeta.map((k, v) => MapEntry(k, v.toString())),
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory AssetModel.fromEntity(Asset e) {
    return AssetModel(
      id: e.id,
      userId: e.userId,
      ticker: e.ticker,
      name: e.name,
      kind: e.kind,
      market: e.market,
      currency: e.currency,
      institutionId: e.institutionId,
      metadata: e.metadata,
      createdAt: e.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ticker': ticker,
      'name': name,
      'kind': kind.name,
      'market': market.name,
      'currency': currency.name,
      if (institutionId != null) 'institutionId': institutionId,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
