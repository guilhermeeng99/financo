import 'package:financo/features/accounts/domain/entities/account_entity.dart';

class AccountFactory {
  const AccountFactory._();

  static AccountEntity checking({
    String id = 'acc-checking-1',
    String userId = 'user-1',
    String name = 'Nubank Checking',
    BankType bank = BankType.nubank,
    double initialBalance = 1000,
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id,
      userId: userId,
      name: name,
      type: AccountType.checking,
      bank: bank,
      initialBalance: initialBalance,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static AccountEntity creditCard({
    String id = 'acc-cc-1',
    String userId = 'user-1',
    String name = 'Nubank Credit Card',
    BankType bank = BankType.nubank,
    double initialBalance = 500,
    double creditLimit = 5000,
    int closingDay = 3,
    int dueDay = 10,
    String linkedAccountId = 'acc-checking-1',
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id,
      userId: userId,
      name: name,
      type: AccountType.creditCard,
      bank: bank,
      initialBalance: initialBalance,
      creditLimit: creditLimit,
      closingDay: closingDay,
      dueDay: dueDay,
      linkedAccountId: linkedAccountId,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static AccountEntity investment({
    String id = 'acc-inv-1',
    String userId = 'user-1',
    String name = 'XP Investimentos',
    BankType bank = BankType.xp,
    double initialBalance = 10000,
    double? currentBalance,
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id,
      userId: userId,
      name: name,
      type: AccountType.investment,
      bank: bank,
      initialBalance: initialBalance,
      currentBalance: currentBalance,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static List<AccountEntity> list() {
    return [
      checking(),
      checking(
        id: 'acc-checking-2',
        name: 'Other Bank',
        bank: BankType.others,
        initialBalance: 2000,
      ),
      creditCard(),
    ];
  }
}
