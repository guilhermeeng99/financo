import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.bank,
    required super.initialBalance,
    required super.createdAt,
    super.creditLimit,
    super.closingDay,
    super.dueDay,
    super.linkedAccountId,
  });

  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    return AccountModel.fromMap(
      id: doc.id,
      data: doc.data()! as Map<String, dynamic>,
    );
  }

  factory AccountModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final bankStr = data['bank'] as String? ?? 'others';
    final bankType =
        BankType.values.where((b) => b.name == bankStr).firstOrNull ??
        BankType.others;
    return AccountModel(
      id: id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      type: AccountType.values.byName(data['type'] as String),
      bank: bankType,
      initialBalance: (data['balance'] as num).toDouble(),
      creditLimit: (data['creditLimit'] as num?)?.toDouble(),
      closingDay: data['closingDay'] as int?,
      dueDay: data['dueDay'] as int?,
      linkedAccountId: data['linkedAccountId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      bank: entity.bank,
      initialBalance: entity.initialBalance,
      creditLimit: entity.creditLimit,
      closingDay: entity.closingDay,
      dueDay: entity.dueDay,
      linkedAccountId: entity.linkedAccountId,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'type': type.name,
      'bank': bank.name,
      'balance': initialBalance,
      'creditLimit': creditLimit,
      'closingDay': closingDay,
      'dueDay': dueDay,
      'linkedAccountId': linkedAccountId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
