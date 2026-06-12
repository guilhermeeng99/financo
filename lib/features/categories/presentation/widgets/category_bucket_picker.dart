import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/entities/category_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Three-way pill toggle for the 50/30/20 bucket: Needs / Wants /
/// Unclassified. Renders only for expense categories — the parent gates
/// visibility. Tapping the currently selected pill clears the bucket
/// (so the user can revert to "unclassified" without going via the
/// type toggle).
class CategoryBucketPicker extends StatelessWidget {
  const CategoryBucketPicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final CategoryBucket? selected;
  final ValueChanged<CategoryBucket?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final entries = <_BucketEntry>[
      _BucketEntry(
        value: CategoryBucket.needs,
        label: t.categories.bucketNeeds,
        icon: FontAwesomeIcons.house,
        tint: colors.primary,
      ),
      _BucketEntry(
        value: CategoryBucket.wants,
        label: t.categories.bucketWants,
        icon: FontAwesomeIcons.heart,
        tint: colors.warning,
      ),
      _BucketEntry(
        value: null,
        label: t.categories.bucketUnclassified,
        icon: FontAwesomeIcons.circleQuestion,
        tint: colors.onBackgroundLight,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final e in entries)
            Expanded(
              child: _BucketSegment(
                entry: e,
                isSelected: e.value == selected,
                onTap: () => onChanged(e.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _BucketEntry {
  const _BucketEntry({
    required this.value,
    required this.label,
    required this.icon,
    required this.tint,
  });

  final CategoryBucket? value;
  final String label;
  final FaIconData icon;
  final Color tint;
}

class _BucketSegment extends StatelessWidget {
  const _BucketSegment({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  final _BucketEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = isSelected ? entry.tint : colors.onBackgroundLight;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? entry.tint.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(entry.icon, size: 14, color: foreground),
                const SizedBox(height: 6),
                Text(
                  entry.label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
