import '../../domain/index.dart';
import '../../presentation/index.dart';

class AccountValidationHelper {
  static bool hasNoStandardChanges({
    required AccountData currentAccount,
    AccountName? name,
    Balance? initialBalance,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) {
    return (name == null || name.value == currentAccount.name) &&
        (initialBalance == null ||
            initialBalance.value == currentAccount.initialBalance) &&
        (currencyType == null || currencyType == currentAccount.currencyType) &&
        (isActive == null || isActive == currentAccount.isActive) &&
        (iconType == null || iconType == currentAccount.iconType) &&
        (initDate == null || _datesAreEqual(initDate, currentAccount.initDate));
  }

  static bool hasNoCreditCardChanges({
    required AccountData currentAccount,
    AccountName? name,
    CreditLimit? creditLimit,
    DateTime? firstBillDueDate,
    BillClosingDay? billClosingDay,
    int? paymentAccountId,
    CurrencyType? currencyType,
    bool? isActive,
    AccountIconType? iconType,
    DateTime? initDate,
  }) {
    return (name == null || name.value == currentAccount.name) &&
        (creditLimit == null ||
            creditLimit.value == currentAccount.creditLimit) &&
        (firstBillDueDate == null ||
            (currentAccount.firstBillDueDate != null &&
                _datesAreEqual(
                  firstBillDueDate,
                  currentAccount.firstBillDueDate!,
                ))) &&
        (billClosingDay == null ||
            billClosingDay.value == currentAccount.billClosingDay) &&
        (paymentAccountId == null ||
            paymentAccountId == currentAccount.paymentAccountId) &&
        (currencyType == null || currencyType == currentAccount.currencyType) &&
        (isActive == null || isActive == currentAccount.isActive) &&
        (iconType == null || iconType == currentAccount.iconType) &&
        (initDate == null || _datesAreEqual(initDate, currentAccount.initDate));
  }

  static bool _datesAreEqual(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day &&
        date1.hour == date2.hour &&
        date1.minute == date2.minute &&
        date1.second == date2.second;
  }
}
