import 'package:equatable/equatable.dart';

enum AccountType { checking, creditCard }

enum BankType { nubank, others }

class AccountEntity extends Equatable {
  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.bank,
    required this.initialBalance,
    required this.isActive,
    required this.createdAt,
    this.creditLimit,
    this.closingDay,
    this.dueDay,
    this.linkedAccountId,
  });

  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final BankType bank;
  final double initialBalance;
  final double? creditLimit;
  final int? closingDay;
  final int? dueDay;
  final String? linkedAccountId;
  final bool isActive;
  final DateTime createdAt;

  double get availableCredit =>
      creditLimit != null ? creditLimit! - initialBalance : 0;

  String get bankLabel => switch (bank) {
    BankType.nubank => 'Nubank',
    BankType.others => 'Others',
  };

  AccountEntity copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    BankType? bank,
    double? initialBalance,
    double? creditLimit,
    int? closingDay,
    int? dueDay,
    String? linkedAccountId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      bank: bank ?? this.bank,
      initialBalance: initialBalance ?? this.initialBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
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
    initialBalance,
    creditLimit,
    closingDay,
    dueDay,
    linkedAccountId,
    isActive,
    createdAt,
  ];
}
