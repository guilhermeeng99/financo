import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';

class AssetClassModel extends AssetClassEntity {
  const AssetClassModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.icon,
    required super.color,
    required super.targetPercent,
    required super.createdAt,
    super.parentId,
  });

  factory AssetClassModel.fromFirestore(DocumentSnapshot doc) {
    return AssetClassModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory AssetClassModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final createdAtRaw = data['createdAt'];
    return AssetClassModel(
      id: id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      icon: data['icon'] as int,
      color: data['color'] as int,
      targetPercent: (data['targetPercent'] as num?)?.toDouble() ?? 0,
      parentId: data['parentId'] as String?,
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory AssetClassModel.fromEntity(AssetClassEntity entity) {
    return AssetClassModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      targetPercent: entity.targetPercent,
      parentId: entity.parentId,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'targetPercent': targetPercent,
      // Only persist when non-null — root rows skip the field entirely
      // so Firestore documents stay clean.
      if (parentId != null) 'parentId': parentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
