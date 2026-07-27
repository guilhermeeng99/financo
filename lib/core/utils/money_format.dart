import 'package:financo/core/money/money.dart';
import 'package:financo/core/utils/currency_formatter.dart';

/// Money/percentage display helpers shared by the investing screens (overview,
/// allocation, allocation detail). Extracted so the same signed/abs/percent
/// formatting isn't re-implemented per page.

/// Signed money: `+R$ 10,00` for positives; zero and negatives print as-is
/// (the minus already comes from the currency formatter).
String signedMoney(Money money) => money.isNegative || money.isZero
    ? formatMoney(money)
    : '+${formatMoney(money)}';

/// The absolute value of [money], formatted — for suggestions where a verb
/// (add/trim/above/below) already conveys direction, so the sign is dropped.
String absMoney(Money money) =>
    formatMoney(Money(money.minorUnits.abs(), money.currency));

/// A signed percentage from a 0–1 ratio, two decimals: `0.12` → `+12.00%`,
/// `-0.05` → `-5.00%`.
String signedPercent(double ratio) {
  final pct = ratio * 100;
  final sign = pct > 0 ? '+' : '';
  return '$sign${pct.toStringAsFixed(2)}%';
}

/// A 0–1 fraction as a one-decimal percent: `0.451` → `45.1%`.
String percentFraction(double fraction) =>
    '${(fraction * 100).toStringAsFixed(1)}%';
