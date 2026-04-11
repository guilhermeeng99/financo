import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/auth/domain/entities/user_entity.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

class AppDataCache {
  UserEntity? currentUser;
  List<AccountEntity>? accounts;
  List<CategoryEntity>? categories;
  List<TransactionEntity>? transactions;
  DashboardSummary? dashboardSummary;

  bool get isFullyLoaded =>
      accounts != null && categories != null && transactions != null;

  void clear() {
    currentUser = null;
    accounts = null;
    categories = null;
    transactions = null;
    dashboardSummary = null;
  }
}
