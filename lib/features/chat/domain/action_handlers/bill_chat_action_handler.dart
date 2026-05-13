import 'package:financo/core/utils/currency_formatter.dart';
import 'package:financo/core/utils/date_helpers.dart' as date_helpers;
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:financo/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:financo/features/bills/domain/entities/bill_entity.dart';
import 'package:financo/features/bills/domain/usecases/create_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:financo/features/bills/domain/usecases/pay_bill_usecase.dart';
import 'package:financo/features/bills/domain/usecases/update_bill_usecase.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:financo/features/chat/domain/action_handlers/chat_action_handler.dart';
import 'package:financo/gen/i18n/strings.g.dart';

class BillChatActionHandler implements ChatActionHandler {
  BillChatActionHandler({
    required GetBillsUseCase getBills,
    required CreateBillUseCase createBill,
    required UpdateBillUseCase updateBill,
    required DeleteBillUseCase deleteBill,
    required PayBillUseCase payBill,
    required GetAccountsUseCase getAccounts,
    required GetCategoriesUseCase getCategories,
  }) : _getBills = getBills,
       _createBill = createBill,
       _updateBill = updateBill,
       _deleteBill = deleteBill,
       _payBill = payBill,
       _getAccounts = getAccounts,
       _getCategories = getCategories;

  final GetBillsUseCase _getBills;
  final CreateBillUseCase _createBill;
  final UpdateBillUseCase _updateBill;
  final DeleteBillUseCase _deleteBill;
  final PayBillUseCase _payBill;
  final GetAccountsUseCase _getAccounts;
  final GetCategoriesUseCase _getCategories;

  @override
  Future<String?> preflight({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async => null;

  @override
  Future<String> handle({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final action = meta['action'] as String?;
    switch (action) {
      case 'create':
        return _create(userId: userId, meta: meta, locale: locale);
      case 'update':
        return _update(userId: userId, meta: meta, locale: locale);
      case 'markPaid':
        return _markPaid(userId: userId, meta: meta, locale: locale);
      case 'delete':
        return _delete(meta: meta, locale: locale);
      default:
        return locale.translations.chat.handlers.unknownBillAction;
    }
  }

  Future<String> _create({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final description = (meta['description'] as String? ?? '').trim();
    if (description.isEmpty) {
      return strings.chat.handlers.billDescriptionRequired;
    }
    final amount = (meta['amount'] as num?)?.toDouble() ?? 0;
    if (amount <= 0) return strings.chat.handlers.billAmountInvalid;
    final dueStr = meta['dueDate'] as String?;
    final dueDate = dueStr != null
        ? DateTime.tryParse(dueStr) ?? DateTime.now()
        : DateTime.now();
    final recurrenceStr = meta['recurrence'] as String? ?? 'oneShot';
    final recurrence = recurrenceStr == 'monthly'
        ? BillRecurrence.monthly
        : BillRecurrence.oneShot;
    final typeStr = meta['type'] as String?;
    final billType = typeStr == 'receivable'
        ? BillType.receivable
        : BillType.payable;

    String? categoryId;
    final categoryName = meta['category'] as String?;
    if (categoryName != null && categoryName.isNotEmpty) {
      final catResult = await _getCategories(userId: userId);
      final categories = catResult.getOrElse(() => []);
      final match = categories
          .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
          .toList();
      if (match.isNotEmpty) categoryId = match.first.id;
    }

    final now = DateTime.now();
    final bill = BillEntity(
      id: '',
      userId: userId,
      type: billType,
      description: description,
      amount: amount,
      dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
      status: BillStatus.pending,
      recurrence: recurrence,
      categoryId: categoryId,
      notes: meta['notes'] as String?,
      createdAt: now,
      updatedAt: now,
    );

    final result = await _createBill(bill);
    return result.fold(
      (f) => strings.chat.handlers.billCreateFailed(error: f.message),
      (b) => strings.chat.handlers.billCreated(
        description: b.description,
        amount: formatCurrency(b.amount),
        dueDate: date_helpers.formatDate(b.dueDate, locale: locale.intlTag),
      ),
    );
  }

  Future<String> _update({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final billId = meta['billId'] as String?;
    if (billId == null || billId.isEmpty) {
      return strings.chat.handlers.billIdRequired;
    }
    final billsResult = await _getBills(userId: userId);
    final bills = billsResult.getOrElse(() => []);
    final existing = bills.where((b) => b.id == billId).toList();
    if (existing.isEmpty) return strings.chat.handlers.billNotFound;
    final current = existing.first;
    if (current.status == BillStatus.paid) {
      return strings.chat.handlers.billCannotEditPaid;
    }

    final newAmount = (meta['amount'] as num?)?.toDouble() ?? current.amount;
    final newDueStr = meta['dueDate'] as String?;
    final newDue = newDueStr != null
        ? DateTime.tryParse(newDueStr) ?? current.dueDate
        : current.dueDate;
    final newDescription =
        (meta['description'] as String?)?.trim() ?? current.description;

    final updated = current.copyWith(
      description: newDescription,
      amount: newAmount,
      dueDate: DateTime(newDue.year, newDue.month, newDue.day),
      notes: meta['notes'] as String? ?? current.notes,
      updatedAt: DateTime.now(),
    );

    final result = await _updateBill(updated);
    return result.fold(
      (f) => strings.chat.handlers.billUpdateFailed(error: f.message),
      (b) => strings.chat.handlers.billUpdated(description: b.description),
    );
  }

  Future<String> _markPaid({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final billId = meta['billId'] as String?;
    if (billId == null || billId.isEmpty) {
      return strings.chat.handlers.billIdRequired;
    }
    final billsResult = await _getBills(userId: userId);
    final bills = billsResult.getOrElse(() => []);
    final existing = bills.where((b) => b.id == billId).toList();
    if (existing.isEmpty) return strings.chat.handlers.billNotFound;
    final bill = existing.first;
    if (bill.status == BillStatus.paid) {
      return strings.chat.handlers.billAlreadyPaid;
    }

    // Default to first checking account + bill's category (or first expense
    // category) so the chat can mark-as-paid without follow-up dialogs. The
    // user can always edit the resulting transaction later.
    final accResult = await _getAccounts(userId: userId);
    final accounts = accResult.getOrElse(() => []);
    final checking = accounts
        .where((a) => a.type == AccountType.checking)
        .toList();
    if (checking.isEmpty) return strings.chat.handlers.billNoCheckingAccount;

    var categoryId = bill.categoryId;
    if (categoryId == null) {
      final catResult = await _getCategories(userId: userId);
      final cats = catResult.getOrElse(() => []);
      final wantedType = bill.isReceivable
          ? CategoryType.income
          : CategoryType.expense;
      final matching = cats.where((c) => c.type == wantedType).toList();
      if (matching.isEmpty) {
        return bill.isReceivable
            ? strings.chat.handlers.billNoIncomeCategory
            : strings.chat.handlers.billNoExpenseCategory;
      }
      categoryId = matching.first.id;
    }

    final result = await _payBill(
      billId: bill.id,
      accountId: checking.first.id,
      categoryId: categoryId,
    );
    return result.fold(
      (f) => strings.chat.handlers.billPayFailed(error: f.message),
      (r) {
        final next = r.nextOccurrence;
        if (next == null) {
          return strings.chat.handlers
              .billPaid(description: r.paidBill.description);
        }
        return strings.chat.handlers.billPaidWithNext(
          description: r.paidBill.description,
          dueDate:
              date_helpers.formatDate(next.dueDate, locale: locale.intlTag),
        );
      },
    );
  }

  Future<String> _delete({
    required Map<String, dynamic> meta,
    required AppLocale locale,
  }) async {
    final strings = locale.translations;
    final billId = meta['billId'] as String?;
    if (billId == null || billId.isEmpty) {
      return strings.chat.handlers.billIdRequired;
    }
    final result = await _deleteBill(billId);
    return result.fold(
      (f) => strings.chat.handlers.billDeleteFailed(error: f.message),
      (_) => strings.chat.handlers.billDeleted,
    );
  }
}
