/// Curated color palette used by the category accent picker and the
/// auto-assignment fallback. The palette is intentionally broad — three
/// to four shades per major hue family — so users have real choice
/// without having to step into a custom color picker.
class CategoryColors {
  const CategoryColors._();

  /// Available category colors as ARGB int values, ordered by hue so the
  /// picker grid reads as a rainbow. Hex literals are easier to audit
  /// than the equivalent decimal ARGB ints.
  static const palette = <int>[
    // Reds
    0xFFEF5350,
    0xFFF44336,
    0xFFD32F2F,
    0xFFB71C1C,
    // Oranges
    0xFFFF7043,
    0xFFFF5722,
    0xFFFF9800,
    0xFFFFB74D,
    // Yellows / amber
    0xFFFFC107,
    0xFFFFEB3B,
    0xFFFFD54F,
    // Limes / greens
    0xFFD4E157,
    0xFF8BC34A,
    0xFF66BB6A,
    0xFF4CAF50,
    0xFF2E7D32,
    // Teals / cyan
    0xFF26A69A,
    0xFF009688,
    0xFF00BCD4,
    0xFF0097A7,
    // Blues
    0xFF03A9F4,
    0xFF2196F3,
    0xFF1976D2,
    0xFF0D47A1,
    // Indigos / deep purples
    0xFF3F51B5,
    0xFF5C6BC0,
    0xFF673AB7,
    0xFF7E57C2,
    // Purples / pinks
    0xFF9C27B0,
    0xFFBA68C8,
    0xFFE91E63,
    0xFFF06292,
    0xFFAD1457,
    // Browns / neutrals
    0xFF795548,
    0xFFA1887F,
    0xFF5D4037,
    0xFF607D8B,
    0xFF455A64,
    0xFF9E9E9E,
  ];

  /// Returns a color for the given index, cycling through [palette].
  static int forIndex(int index) => palette[index % palette.length];
}
