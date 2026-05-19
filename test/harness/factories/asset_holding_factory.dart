import 'package:financo/features/investments/domain/entities/asset_holding_entity.dart';

class AssetHoldingFactory {
  const AssetHoldingFactory._();

  static AssetHoldingEntity holding({
    String id = 'holding-1',
    String userId = 'user-1',
    String accountId = 'acc-inv-1',
    String assetClassId = 'class-stocks',
    double amount = 1000,
    String? notes,
    DateTime? updatedAt,
  }) {
    return AssetHoldingEntity(
      id: id,
      userId: userId,
      accountId: accountId,
      assetClassId: assetClassId,
      amount: amount,
      notes: notes,
      updatedAt: updatedAt ?? DateTime(2024),
    );
  }
}
