import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Text(category.name),
      avatar: Icon(
        IconData(category.icon, fontFamily: 'MaterialIcons'),
        size: 18,
        color: Color(category.color),
      ),
      onSelected: (_) => onTap?.call(),
    );
  }
}
