import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Single category row used in the categories list. Subcategories are
/// indented and rendered in a slightly muted variant so the parent/child
/// hierarchy is visible at a glance.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    required this.category,
    required this.parentName,
    required this.onTap,
    super.key,
  });

  final CategoryEntity category;
  final String? parentName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isSub = category.isSubcategory;
    final categoryColor = Color(category.color);

    return Padding(
      padding: EdgeInsets.only(
        left: isSub ? 24 : 0,
        bottom: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _IconDisc(
                    iconCode: category.icon,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: colors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitleFor(context),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onBackgroundLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 12,
                    color: colors.onBackgroundLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(BuildContext context) {
    if (category.isSubcategory) {
      final base = parentName ?? t.categories.parentCategory;
      return '$base · ${t.categories.subcategoryLabel}';
    }
    return category.type == CategoryType.income
        ? t.categories.incomeType
        : t.categories.expenseType;
  }
}

class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.iconCode, required this.color});

  final int iconCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          IconData(iconCode, fontFamily: 'MaterialIcons'),
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
