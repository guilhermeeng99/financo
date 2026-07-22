/// Currencies the investing module can hold and consolidate. BRL is the base.
///
/// Used only by the V2 investing module (see `docs/specs/investing.md` §2). The
/// cash side of the app remains BRL `double`.
///
/// Example:
/// ```dart
/// final c = Currency.usd;
/// c.code;   // 'USD'
/// c.symbol; // r'$'
/// ```
enum Currency {
  brl('BRL', r'R$', 'pt_BR'),
  usd('USD', r'$', 'en_US'),
  // Euro. `de_DE` formats it the way a BR user expects — `.` grouping, `,`
  // decimal, symbol trailing (`1.234,56 €`) — matching BRL/USD separators.
  eur('EUR', '€', 'de_DE');

  const Currency(this.code, this.symbol, this.locale);

  /// ISO 4217 code (e.g. `BRL`).
  final String code;

  /// Display symbol (e.g. `R$`).
  final String symbol;

  /// Locale used for number formatting (e.g. `pt_BR`).
  final String locale;
}
