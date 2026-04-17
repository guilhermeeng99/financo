import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

class TransactionFactory {
  const TransactionFactory._();

  static TransactionEntity expense({
    String id = 'tx-expense-1',
    String userId = 'user-1',
    String accountId = 'acc-1',
    String categoryId = 'cat-1',
    double amount = 150,
    String description = 'Groceries',
    DateTime? date,
    String? notes,
    String? linkedTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = createdAt ?? DateTime(2024, 3, 15);
    return TransactionEntity(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      type: TransactionType.expense,
      amount: amount,
      description: description,
      date: date ?? DateTime(2024, 3, 15),
      notes: notes,
      linkedTransactionId: linkedTransactionId,
      createdAt: now,
      updatedAt: updatedAt ?? now,
    );
  }

  static TransactionEntity income({
    String id = 'tx-income-1',
    String userId = 'user-1',
    String accountId = 'acc-1',
    String categoryId = 'cat-2',
    double amount = 3000,
    String description = 'Salary',
    DateTime? date,
    String? notes,
    String? linkedTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = createdAt ?? DateTime(2024, 3, 5);
    return TransactionEntity(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      type: TransactionType.income,
      amount: amount,
      description: description,
      date: date ?? DateTime(2024, 3, 5),
      notes: notes,
      linkedTransactionId: linkedTransactionId,
      createdAt: now,
      updatedAt: updatedAt ?? now,
    );
  }

  static ({TransactionEntity expense, TransactionEntity income}) transfer({
    String expenseId = 'tx-transfer-exp',
    String incomeId = 'tx-transfer-inc',
    String userId = 'user-1',
    String sourceAccountId = 'acc-1',
    String destinationAccountId = 'acc-2',
    double amount = 500,
    String description = 'Transfer',
    DateTime? date,
  }) {
    final txDate = date ?? DateTime(2024, 3, 20);
    final now = txDate;
    return (
      expense: TransactionEntity(
        id: expenseId,
        userId: userId,
        accountId: sourceAccountId,
        categoryId: '',
        type: TransactionType.expense,
        amount: amount,
        description: description,
        date: txDate,
        linkedTransactionId: incomeId,
        createdAt: now,
        updatedAt: now,
      ),
      income: TransactionEntity(
        id: incomeId,
        userId: userId,
        accountId: destinationAccountId,
        categoryId: '',
        type: TransactionType.income,
        amount: amount,
        description: description,
        date: txDate,
        linkedTransactionId: expenseId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  static List<TransactionEntity> list() {
    return [
      income(),
      expense(),
      expense(
        id: 'tx-expense-2',
        amount: 45,
        description: 'Coffee',
        date: DateTime(2024, 3, 18),
      ),
    ];
  }
}
