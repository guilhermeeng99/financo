import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Read-only field on the category form showing the selected parent
/// category (or the "no parent" placeholder) and opening the parent
/// picker via [onTap]. [selectedName] is the resolved parent name —
/// `null` means the category is (or will be) a root.
class ParentCategoryField extends StatelessWidget {
  const ParentCategoryField({
    required this.selectedName,
    required this.onTap,
    super.key,
  });

  final String? selectedName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = selectedName != null;
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.folderTree,
                size: 14,
                color: colors.onBackgroundLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.categories.parentCategory,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? selectedName! : t.categories.noParentChosen,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: hasValue
                            ? colors.onBackground
                            : colors.onBackgroundLight,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 11,
                color: colors.onBackgroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
