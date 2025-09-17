import 'package:app_database/app_database.dart';

class AccountFormData {
  AccountFormData({
    this.name = '',
    this.initialBalance = 0.0,
    this.accountType = AccountType.checking,
    this.currencyType = CurrencyType.brl,
    this.iconType = AccountIconType.none,
    DateTime? initDate,
  }) : initDate = initDate ?? DateTime.now();

  factory AccountFormData.fromAccount(AccountData account) {
    return AccountFormData(
      name: account.name,
      initialBalance: account.initialBalance,
      accountType: account.accountType,
      currencyType: account.currencyType,
      iconType: account.iconType,
      initDate: account.initDate,
    );
  }

  final String name;
  final double initialBalance;
  final AccountType accountType;
  final CurrencyType currencyType;
  final AccountIconType iconType;
  final DateTime initDate;

  AccountFormData copyWith({
    String? name,
    double? initialBalance,
    AccountType? accountType,
    CurrencyType? currencyType,
    AccountIconType? iconType,
    DateTime? initDate,
  }) {
    return AccountFormData(
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      accountType: accountType ?? this.accountType,
      currencyType: currencyType ?? this.currencyType,
      iconType: iconType ?? this.iconType,
      initDate: initDate ?? this.initDate,
    );
  }
}

class AccountFormErrors {
  const AccountFormErrors({this.name = '', this.initialBalance = ''});

  final String name;
  final String initialBalance;

  bool get hasErrors => name.isNotEmpty || initialBalance.isNotEmpty;

  AccountFormErrors copyWith({String? name, String? initialBalance}) {
    return AccountFormErrors(
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
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
  });

  final AccountName name;
  final AccountType accountType;
  final Balance initialBalance;
  final CurrencyType currencyType;
  final AccountIconType iconType;
  final DateTime initDate;
}

class CreateAccountParams extends BaseAccountParams {
  const CreateAccountParams({
    required super.name,
    required super.accountType,
    required super.initialBalance,
    required super.currencyType,
    required super.iconType,
    required super.initDate,
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
  });

  final int id;
}
