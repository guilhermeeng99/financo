import 'package:equatable/equatable.dart';

enum AccountType { checking, creditCard }

class AccountEntity extends Equatable {
  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.bank,
    required this.balance,
    required this.isActive,
    required this.createdAt,
    this.creditLimit,
    this.closingDay,
    this.dueDay,
  });

  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final String bank;
  final double balance;
  final double? creditLimit;
  final int? closingDay;
  final int? dueDay;
  final bool isActive;
  final DateTime createdAt;

  double get availableCredit =>
      creditLimit != null ? creditLimit! - balance : 0;

  AccountEntity copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    String? bank,
    double? balance,
    double? creditLimit,
    int? closingDay,
    int? dueDay,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    type,
    bank,
    balance,
    creditLimit,
    closingDay,
    dueDay,
    isActive,
    createdAt,
  ];
}
