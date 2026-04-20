/// Fixed color palette for category auto-assignment.
///
/// Colors are assigned by cycling through the palette based on the
/// number of existing categories at creation time.
class CategoryColors {
  const CategoryColors._();

  /// Available category colors as ARGB int values.
  static const palette = <int>[
    4294198070, // red
    4294940672, // orange
    4294961979, // yellow
    4283215696, // green
    4280391411, // blue
    4284955975, // purple
    4288585374, // pink
    4278228616, // teal
    4280191205, // indigo
    4284513675, // deep purple
    4293467747, // deep orange
    4281559326, // cyan
    4285132974, // brown
    4284790262, // blue grey
    4278238420, // light green
  ];

  /// Returns a color for the given index, cycling through [palette].
  static int forIndex(int index) => palette[index % palette.length];
}
