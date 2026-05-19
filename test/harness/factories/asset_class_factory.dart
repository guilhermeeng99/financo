import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';

class AssetClassFactory {
  const AssetClassFactory._();

  static AssetClassEntity stocks({
    String id = 'class-stocks',
    String userId = 'user-1',
    String name = 'Ações',
    int icon = 0xf201,
    int color = 0xFF5B5FEF,
    double targetPercent = 25,
    DateTime? createdAt,
  }) {
    return AssetClassEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      targetPercent: targetPercent,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static AssetClassEntity realEstate({
    String id = 'class-re',
    String userId = 'user-1',
    String name = 'Real Estate',
    int icon = 0xf015,
    int color = 0xFF22C55E,
    double targetPercent = 25,
    DateTime? createdAt,
  }) {
    return AssetClassEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      targetPercent: targetPercent,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static AssetClassEntity crypto({
    String id = 'class-crypto',
    String userId = 'user-1',
    String name = 'Bitcoin',
    int icon = 0xf15a,
    int color = 0xFFF59E0B,
    double targetPercent = 25,
    DateTime? createdAt,
  }) {
    return AssetClassEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      targetPercent: targetPercent,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static AssetClassEntity fixedIncome({
    String id = 'class-fi',
    String userId = 'user-1',
    String name = 'Renda Fixa',
    int icon = 0xf02d,
    int color = 0xFFEF4444,
    double targetPercent = 25,
    DateTime? createdAt,
  }) {
    return AssetClassEntity(
      id: id,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      targetPercent: targetPercent,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  /// Default ARCA quartet — 25/25/25/25 split.
  static List<AssetClassEntity> arcaList() => [
    stocks(),
    realEstate(),
    crypto(),
    fixedIncome(),
  ];

  /// Subclass helper — inherits the parent's icon + color, persists
  /// `targetPercent: 0` per spec rule 3.
  static AssetClassEntity subclass({
    required String id,
    required String name,
    required AssetClassEntity parent,
    String userId = 'user-1',
    DateTime? createdAt,
  }) {
    return AssetClassEntity(
      id: id,
      userId: userId,
      name: name,
      icon: parent.icon,
      color: parent.color,
      targetPercent: 0,
      parentId: parent.id,
      createdAt: createdAt ?? DateTime(2024),
    );
  }
}
