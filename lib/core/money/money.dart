import 'package:equatable/equatable.dart';
import 'package:financo/core/money/currency.dart';

/// A monetary amount stored as integer **minor units** (e.g. cents) to avoid
/// floating-point drift in financial math.
///
/// Used only by the V2 investing module (see `docs/specs/investing.md` §2). The
/// cash side of the app keeps its BRL `double` representation.
///
/// Example:
/// ```dart
/// final price = Money.fromMajor(10.50, Currency.brl); // R$10,50
/// final total = price * 3;                            // R$31,50
/// ```
class Money extends Equatable {
  const Money(this.minorUnits, this.currency);

  /// Builds [Money] from a major-unit value (e.g. reais), rounding to cents.
  factory Money.fromMajor(double major, Currency currency) =>
      Money((major * 100).round(), currency);

  /// A zero amount in [currency].
  const Money.zero(this.currency) : minorUnits = 0;

  /// The amount in the smallest unit of the currency (cents for BRL/USD).
  final int minorUnits;

  /// The currency this amount is denominated in.
  final Currency currency;

  /// The amount in major units (e.g. 1051 → 10.51).
  double get major => minorUnits / 100;

  /// Whether the amount is exactly zero.
  bool get isZero => minorUnits == 0;

  /// Whether the amount is negative.
  bool get isNegative => minorUnits < 0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits - other.minorUnits, currency);
  }

  /// Scales the amount by a quantity/factor, rounding to the nearest cent.
  Money operator *(num factor) =>
      Money((minorUnits * factor).round(), currency);

  /// Guards against combining different currencies. Throws (not `assert`) so a
  /// currency mix fails loudly in release too — silently summing BRL + USD
  /// minor units would corrupt totals. Conversions must go through FX first.
  void _assertSameCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Cannot combine $currency with ${other.currency}',
      );
    }
  }

  @override
  List<Object?> get props => [minorUnits, currency];

  @override
  String toString() => '${currency.code} ${major.toStringAsFixed(2)}';
}
