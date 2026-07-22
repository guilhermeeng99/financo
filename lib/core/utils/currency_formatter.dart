import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: r'R$',
  decimalDigits: 2,
);

/// Formats a BRL [double] amount (the cash side of the app) as `R$ 1.234,56`.
String formatCurrency(double value) => _currencyFormat.format(value);

/// Cached per-currency formatters — building a [NumberFormat] is not free and
/// there are only three currencies.
final _moneyFormats = <Currency, NumberFormat>{};

/// Formats a multi-currency [Money] amount using its own locale and symbol —
/// `R$ 1.234,56`, `$1,234.56`, `1.234,56 €`.
///
/// Used by the V2 investing module (see `docs/specs/investing.md` §2). Kept
/// separate from [formatCurrency] because Dart has no function overloading and
/// the cash side stays BRL `double`.
///
/// Example:
/// ```dart
/// formatMoney(Money.fromMajor(1234.56, Currency.usd)); // "$1,234.56"
/// ```
String formatMoney(Money value) => _moneyFormats
    .putIfAbsent(
      value.currency,
      () => NumberFormat.currency(
        locale: value.currency.locale,
        symbol: value.currency.symbol,
        decimalDigits: 2,
      ),
    )
    .format(value.major);
