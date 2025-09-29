import 'package:app_database/app_database.dart';

class AccountFormData {
  AccountFormData({
    this.name = '',
    this.initialBalance = 0.0,
    this.accountType = AccountType.checking,
    this.currencyType = CurrencyType.brl,
    this.iconType = AccountIconType.none,
    DateTime? initDate,
    DateTime? firstBillDueDate,
    this.creditLimit,
    this.billClosingDay = 0,
    this.paymentAccountId,
  }) : initDate = initDate ?? DateTime.now(),
       firstBillDueDate = firstBillDueDate ?? DateTime.now();

  factory AccountFormData.fromAccount(AccountData account) {
    return AccountFormData(
      name: account.name,
      initialBalance: account.initialBalance ?? 0.0,
      accountType: account.accountType,
      currencyType: account.currencyType,
      iconType: account.iconType,
      initDate: account.initDate,
      creditLimit: account.creditLimit,
      firstBillDueDate: account.firstBillDueDate,
      billClosingDay: account.billClosingDay ?? 0,
      paymentAccountId: account.paymentAccountId,
    );
  }

  final String name;
  final double initialBalance;
  final AccountType accountType;
  final CurrencyType currencyType;
  final AccountIconType iconType;
  final DateTime initDate;
  final double? creditLimit;
  final DateTime? firstBillDueDate;
  final int billClosingDay;
  final int? paymentAccountId;

  AccountFormData copyWith({
    String? name,
    double? initialBalance,
    AccountType? accountType,
    CurrencyType? currencyType,
    AccountIconType? iconType,
    DateTime? initDate,
    double? creditLimit,
    DateTime? firstBillDueDate,
    int? billClosingDay,
    int? paymentAccountId,
  }) {
    return AccountFormData(
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      accountType: accountType ?? this.accountType,
      currencyType: currencyType ?? this.currencyType,
      iconType: iconType ?? this.iconType,
      initDate: initDate ?? this.initDate,
      creditLimit: creditLimit ?? this.creditLimit,
      firstBillDueDate: firstBillDueDate ?? this.firstBillDueDate,
      billClosingDay: billClosingDay ?? this.billClosingDay,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
    );
  }
}

class AccountFormErrors {
  const AccountFormErrors({
    this.name = '',
    this.initialBalance = '',
    this.creditLimit = '',
    this.firstBillDueDate = '',
    this.billClosingDay = '',
    this.paymentAccountId = '',
  });

  final String name;
  final String initialBalance;
  final String creditLimit;
  final String firstBillDueDate;
  final String billClosingDay;
  final String paymentAccountId;

  bool get hasErrors =>
      name.isNotEmpty ||
      initialBalance.isNotEmpty ||
      creditLimit.isNotEmpty ||
      firstBillDueDate.isNotEmpty ||
      billClosingDay.isNotEmpty ||
      paymentAccountId.isNotEmpty;

  AccountFormErrors copyWith({
    String? name,
    String? initialBalance,
    String? creditLimit,
    String? firstBillDueDate,
    String? billClosingDay,
    String? paymentAccountId,
  }) {
    return AccountFormErrors(
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      firstBillDueDate: firstBillDueDate ?? this.firstBillDueDate,
      billClosingDay: billClosingDay ?? this.billClosingDay,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
    );
  }

  AccountFormErrors clear() {
    return const AccountFormErrors();
  }
}

abstract class BaseAccountParams {
  const BaseAccountParams({
    required this.name,
    required this.accountType,
    required this.initialBalance,
    required this.currencyType,
    required this.iconType,
    required this.initDate,
    this.creditLimit,
    this.firstBillDueDate,
    this.billClosingDay,
    this.paymentAccountId,
  });

  final AccountName name;
  final AccountType accountType;
  final Balance initialBalance;
  final CurrencyType currencyType;
  final AccountIconType iconType;
  final DateTime initDate;
  final CreditLimit? creditLimit;
  final DateTime? firstBillDueDate;
  final BillClosingDay? billClosingDay;
  final int? paymentAccountId;
}

class CreateAccountParams extends BaseAccountParams {
  const CreateAccountParams({
    required super.name,
    required super.accountType,
    required super.initialBalance,
    required super.currencyType,
    required super.iconType,
    required super.initDate,
    super.creditLimit,
    super.firstBillDueDate,
    super.billClosingDay,
    super.paymentAccountId,
  });
}

class UpdateAccountParams extends BaseAccountParams {
  const UpdateAccountParams({
    required this.id,
    required super.name,
    required super.accountType,
    required super.initialBalance,
    required super.currencyType,
    required super.iconType,
    required super.initDate,
    super.creditLimit,
    super.firstBillDueDate,
    super.billClosingDay,
    super.paymentAccountId,
  });

  final int id;
}
