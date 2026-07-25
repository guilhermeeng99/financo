/// Formats an asset quantity for display, trimming trailing zeros so whole
/// counts read cleanly and fractional ones keep only their significant digits
/// (`3.0` → `3`, `1.5` → `1.5`, `0.10000000` → `0.1`).
///
/// Shared by the investing overview (holding rows) and the CSV import preview
/// so both trim quantities the same way. Quantities are display-only counts,
/// not money — monetary values still go through `formatMoney`/`formatCurrency`.
///
/// Example:
/// ```dart
/// formatQuantity(3);    // '3'
/// formatQuantity(1.5);  // '1.5'
/// ```
String formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) return quantity.toStringAsFixed(0);
  return quantity
      .toStringAsFixed(8)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
