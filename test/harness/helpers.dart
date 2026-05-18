import 'package:financo/features/accounts/data/models/account_model.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/auth/data/models/user_model.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/bills/data/models/bill_model.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_scoped_usecase.dart';
import 'package:financo/features/budgets/data/models/budget_model.dart';
import 'package:financo/features/budgets/domain/entities/budget_entity.dart';
import 'package:financo/features/categories/data/models/category_model.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/chat/data/models/chat_message_model.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_overview.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/transactions/data/models/transaction_model.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:mocktail/mocktail.dart';

void registerCategoryFallbackValues() {
  registerFallbackValue(
    const CategoryEntity(
      id: 'fallback',
      name: 'fallback',
      icon: 58332,
      color: 4280391411,
      type: CategoryType.expense,
    ),
  );
  registerFallbackValue(
    const CategoryModel(
      id: 'fallback',
      name: 'fallback',
      icon: 58332,
      color: 4280391411,
      type: CategoryType.expense,
    ),
  );
}

void registerAccountFallbackValues() {
  registerFallbackValue(
    AccountEntity(
      id: 'fallback',
      userId: 'fallback',
      name: 'fallback',
      type: AccountType.checking,
      bank: BankType.nubank,
      initialBalance: 0,
      createdAt: DateTime(2024),
    ),
  );
  registerFallbackValue(
    AccountModel(
      id: 'fallback',
      userId: 'fallback',
      name: 'fallback',
      type: AccountType.checking,
      bank: BankType.nubank,
      initialBalance: 0,
      createdAt: DateTime(2024),
    ),
  );
}

void registerTransactionFallbackValues() {
  registerFallbackValue(
    TransactionEntity(
      id: 'fallback',
      userId: 'fallback',
      accountId: 'fallback',
      categoryId: 'fallback',
      type: TransactionType.expense,
      amount: 1,
      description: 'fallback',
      date: DateTime(2024),
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
  );
  registerFallbackValue(
    TransactionModel(
      id: 'fallback',
      userId: 'fallback',
      accountId: 'fallback',
      categoryId: 'fallback',
      type: TransactionType.expense,
      amount: 1,
      description: 'fallback',
      date: DateTime(2024),
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
  );
}

void registerChatFallbackValues() {
  registerFallbackValue(
    ChatMessageEntity(
      id: 'fallback',
      userId: 'fallback',
      role: ChatRole.user,
      content: 'fallback',
      createdAt: DateTime(2024),
    ),
  );
  registerFallbackValue(
    ChatMessageModel(
      id: 'fallback',
      userId: 'fallback',
      role: ChatRole.user,
      content: 'fallback',
      createdAt: DateTime(2024),
    ),
  );
  // Slang's `Translations` is required by handler signatures since chat
  // is bilingual — register a concrete instance so mocktail's any(named:
  // 'strings') matcher can resolve.
  registerFallbackValue(AppLocale.en.buildSync());
  registerFallbackValue(AppLocale.en);
}

void registerDashboardFallbackValues() {
  registerFallbackValue(
    const DashboardSummary(
      totalBalance: 0,
      totalIncome: 0,
      totalExpenses: 0,
      netResult: 0,
      accounts: [],
      expensesByCategory: [],
      incomeByCategory: [],
      fiftyThirtyTwenty: FiftyThirtyTwentyOverview.empty,
    ),
  );
  registerFallbackValue(FiftyThirtyTwentyTargets.classic);
}

void registerBillFallbackValues() {
  registerFallbackValue(
    BillEntity(
      id: 'fallback',
      userId: 'fallback',
      type: BillType.payable,
      description: 'fallback',
      amount: 1,
      dueDate: DateTime(2026),
      status: BillStatus.pending,
      recurrence: BillRecurrence.oneShot,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
  registerFallbackValue(
    BillModel(
      id: 'fallback',
      userId: 'fallback',
      type: BillType.payable,
      description: 'fallback',
      amount: 1,
      dueDate: DateTime(2026),
      status: BillStatus.pending,
      recurrence: BillRecurrence.oneShot,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
  registerFallbackValue(BillEditScope.onlyThis);
}

void registerBudgetFallbackValues() {
  registerFallbackValue(
    BudgetEntity(
      id: 'fallback',
      userId: 'fallback',
      categoryId: 'fallback',
      amount: 1,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
  registerFallbackValue(
    BudgetModel(
      id: 'fallback',
      userId: 'fallback',
      categoryId: 'fallback',
      amount: 1,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
}

void registerAuthFallbackValues() {
  registerFallbackValue(
    UserEntity(
      id: 'fallback',
      name: 'fallback',
      email: 'fallback@test.com',
      createdAt: DateTime(2024),
    ),
  );
  registerFallbackValue(
    UserModel(
      id: 'fallback',
      name: 'fallback',
      email: 'fallback@test.com',
      createdAt: DateTime(2024),
    ),
  );
}
