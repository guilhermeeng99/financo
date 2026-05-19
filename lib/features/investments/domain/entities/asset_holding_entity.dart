import 'package:equatable/equatable.dart';

/// A declared allocation of money inside an investment account against
/// a user-defined asset class. Example: "R$ 30.000 da Conta XP estão
/// alocados em Real Estate". The user maintains these manually — the
/// system never writes a holding as a side-effect of a transaction.
///
/// Invariants enforced by the form / use cases:
///
/// * `amount >= 0`.
/// * `Σ(holdings.amount where accountId == X) <= account.effectiveBalance(X)`.
/// * `accountId` must point to an `AccountType.investment` account.
///
/// See `specs/investments.md` for the full feature contract.
class AssetHoldingEntity extends Equatable {
  const AssetHoldingEntity({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.assetClassId,
    required this.amount,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final String userId;
  final String accountId;
  final String assetClassId;
  final double amount;
  final String? notes;
  final DateTime updatedAt;

  AssetHoldingEntity copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? assetClassId,
    double? amount,
    String? notes,
    bool clearNotes = false,
    DateTime? updatedAt,
  }) {
    return AssetHoldingEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      assetClassId: assetClassId ?? this.assetClassId,
      amount: amount ?? this.amount,
      notes: clearNotes ? null : (notes ?? this.notes),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    accountId,
    assetClassId,
    amount,
    notes,
    updatedAt,
  ];
}
