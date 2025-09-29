import 'package:drift/drift.dart';

import '../../../../database/database_manager.dart';
import '../../domain/index.dart';
import '../../presentation/index.dart';

class AccountCompanionBuilder {
  AccountCompanionBuilder._();

  AccountCompanionBuilder.forStandardAccount({
    required AccountName name,
    required Balance initialBalance,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  }) {
    _setName(name);
    _setAccountType(AccountType.checking);
    _setInitialBalance(initialBalance);
    _setCurrencyType(currencyType);
    _setIsActive(true);
    _setIconType(iconType);
    _setInitDate(initDate ?? DateTime.now());
  }

  AccountCompanionBuilder.forCreditCardAccount({
    required AccountName name,
    required CreditLimit creditLimit,
    required DateTime firstBillDueDate,
    required BillClosingDay billClosingDay,
    required int paymentAccountId,
    AccountIconType iconType = AccountIconType.none,
    CurrencyType currencyType = CurrencyType.brl,
    DateTime? initDate,
  }) {
    _setName(name);
    _setAccountType(AccountType.creditCard);
    _setCurrencyType(currencyType);
    _setIsActive(true);
    _setIconType(iconType);
    _setInitDate(initDate ?? DateTime.now());
    _setCreditLimit(creditLimit);
    _setFirstBillDueDate(firstBillDueDate);
    _setBillClosingDay(billClosingDay);
    _setPaymentAccountId(paymentAccountId);
  }

  AccountCompanionBuilder.forUpdate();

  AccountsCompanion _companion = const AccountsCompanion();

  void _setName(AccountName name) {
    _companion = _companion.copyWith(name: Value(name.value));
  }

  void _setAccountType(AccountType accountType) {
    _companion = _companion.copyWith(accountType: Value(accountType));
  }

  void _setInitialBalance(Balance? initialBalance) {
    if (initialBalance != null) {
      _companion = _companion.copyWith(
        initialBalance: Value(initialBalance.value),
      );
    }
  }

  void _setCurrencyType(CurrencyType currencyType) {
    _companion = _companion.copyWith(currencyType: Value(currencyType));
  }

  void _setIsActive(bool isActive) {
    _companion = _companion.copyWith(isActive: Value(isActive));
  }

  void _setIconType(AccountIconType iconType) {
    _companion = _companion.copyWith(iconType: Value(iconType));
  }

  void _setInitDate(DateTime initDate) {
    _companion = _companion.copyWith(initDate: Value(initDate));
  }

  void _setCreditLimit(CreditLimit creditLimit) {
    _companion = _companion.copyWith(creditLimit: Value(creditLimit.value));
  }

  void _setFirstBillDueDate(DateTime firstBillDueDate) {
    _companion = _companion.copyWith(firstBillDueDate: Value(firstBillDueDate));
  }

  void _setBillClosingDay(BillClosingDay billClosingDay) {
    _companion = _companion.copyWith(
      billClosingDay: Value(billClosingDay.value),
    );
  }

  void _setPaymentAccountId(int paymentAccountId) {
    _companion = _companion.copyWith(paymentAccountId: Value(paymentAccountId));
  }

  // Update methods with optional values
  void setName(AccountName? name) {
    if (name != null) {
      _companion = _companion.copyWith(name: Value(name.value));
    }
  }

  void setInitialBalance(Balance? initialBalance) {
    if (initialBalance != null) {
      _companion = _companion.copyWith(
        initialBalance: Value(initialBalance.value),
      );
    }
  }

  void setCurrencyType(CurrencyType? currencyType) {
    if (currencyType != null) {
      _companion = _companion.copyWith(currencyType: Value(currencyType));
    }
  }

  void setIsActive(bool? isActive) {
    if (isActive != null) {
      _companion = _companion.copyWith(isActive: Value(isActive));
    }
  }

  void setIconType(AccountIconType? iconType) {
    if (iconType != null) {
      _companion = _companion.copyWith(iconType: Value(iconType));
    }
  }

  void setInitDate(DateTime? initDate) {
    if (initDate != null) {
      _companion = _companion.copyWith(initDate: Value(initDate));
    }
  }

  void setCreditLimit(CreditLimit? creditLimit) {
    if (creditLimit != null) {
      _companion = _companion.copyWith(creditLimit: Value(creditLimit.value));
    }
  }

  void setFirstBillDueDate(DateTime? firstBillDueDate) {
    if (firstBillDueDate != null) {
      _companion = _companion.copyWith(
        firstBillDueDate: Value(firstBillDueDate),
      );
    }
  }

  void setBillClosingDay(BillClosingDay? billClosingDay) {
    if (billClosingDay != null) {
      _companion = _companion.copyWith(
        billClosingDay: Value(billClosingDay.value),
      );
    }
  }

  void setPaymentAccountId(int? paymentAccountId) {
    if (paymentAccountId != null) {
      _companion = _companion.copyWith(
        paymentAccountId: Value(paymentAccountId),
      );
    }
  }

  AccountsCompanion build() => _companion;
}
