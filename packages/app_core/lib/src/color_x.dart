import 'dart:ui';

extension ColorX on Color {
  Color opacityX(double opacity) {
    return withValues(alpha: opacity);
  }
}
