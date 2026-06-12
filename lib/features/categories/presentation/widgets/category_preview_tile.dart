import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:flutter/material.dart';

/// Live preview of how a category will render (icon chip + name) shown at
/// the top of the category form and the import edit sheet. [icon] is a
/// material codepoint and [color] an ARGB int, matching how categories
/// are persisted.
class CategoryPreviewTile extends StatelessWidget {
  const CategoryPreviewTile({
    required this.name,
    required this.icon,
    required this.color,
    super.key,
  });

  final String name;
  final int icon;
  final int color;

  @override
  Widget build(BuildContext context) {
    final tint = Color(color);
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.18),
            tint.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                materialIconFor(icon),
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
