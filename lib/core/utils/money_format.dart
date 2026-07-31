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

/// A 0–1 fraction as a whole percent, no suffix: `0.451` → `45`.
///
/// The allocation screens compose their own strings around the number
/// (`'$actual% de $target%'`), so this returns the digits only. Six call sites
/// were hand-rolling `(x * 100).toStringAsFixed(0)`.
String percentWhole(double fraction) => (fraction * 100).toStringAsFixed(0);

/// Trims trailing zeros from a decimal, keeping at most [maxFractionDigits].
///
/// `1.50` → `1.5`, `2.0` → `2`, `1.92012` → `1.9201`. Used for quantities and
/// rates, which read badly at a fixed precision — a holding of 8 shares should
/// not render as `8.0000`. Three separate implementations of this existed
/// (regex, `endsWith('.00')`, and a `roundToDouble` compare) before the
/// 2026-07-31 audit.
///
/// Not for money: monetary values always show their currency's full precision
/// via `formatMoney`/`formatCurrency`.
String compactDecimal(double value, {int maxFractionDigits = 4}) {
  final fixed = value.toStringAsFixed(maxFractionDigits);
  if (!fixed.contains('.')) return fixed;
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
