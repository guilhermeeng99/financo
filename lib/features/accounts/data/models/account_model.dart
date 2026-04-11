import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.bank,
    required super.balance,
    required super.isActive,
    required super.createdAt,
    super.creditLimit,
    super.closingDay,
    super.dueDay,
  });

  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return AccountModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      type: AccountType.values.byName(data['type'] as String),
      bank: data['bank'] as String,
      balance: (data['balance'] as num).toDouble(),
      creditLimit: (data['creditLimit'] as num?)?.toDouble(),
      closingDay: data['closingDay'] as int?,
      dueDay: data['dueDay'] as int?,
      isActive: data['isActive'] as bool,
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
      balance: entity.balance,
      creditLimit: entity.creditLimit,
      closingDay: entity.closingDay,
      dueDay: entity.dueDay,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'type': type.name,
      'bank': bank,
      'balance': balance,
      'creditLimit': creditLimit,
      'closingDay': closingDay,
      'dueDay': dueDay,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
