import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';

/// Square-ish disc rendering the category's icon tinted with the
/// category's brand colour. Two sizes are exposed via [size]; the
/// internal corner radius and icon scale are derived from it so callers
/// only need to pick a target size.
///
/// Pass [allCategories] when rendering a subcategory so it can inherit
/// its parent's icon and color. If the parent is absent, the widget
/// falls back to the category's own stored appearance.
///
/// Usage:
/// ```dart
/// FinancoCategoryAvatar(
///   category: selected,
///   allCategories: categories,
/// );
/// ```
///
/// Replaces the per-feature `_CategoryDot` copies that the bill and
/// transaction forms each maintained.
class FinancoCategoryAvatar extends StatelessWidget {
  const FinancoCategoryAvatar({
    required this.category,
    this.allCategories = const [],
    this.size = 36,
    super.key,
  });

  final CategoryEntity category;
  final Iterable<CategoryEntity> allCategories;
  final double size;

  @override
  Widget build(BuildContext context) {
    final appearance = category.displayAppearance(allCategories);
    final color = Color(appearance.color);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Icon(
          materialIconFor(appearance.icon),
          size: size * 0.5,
          color: color,
        ),
      ),
    );
  }
}
