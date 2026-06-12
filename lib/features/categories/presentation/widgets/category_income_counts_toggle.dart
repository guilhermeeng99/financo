import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Switch row used in the category form when type=income to control
/// whether transactions on this category feed the 50/30/20 base
/// income (the "100%"). Lives next to the bucket picker so income +
/// expense forms expose related controls in the same visual slot.
class CategoryIncomeCountsToggle extends StatelessWidget {
  const CategoryIncomeCountsToggle({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.chartPie,
                size: 14,
                color: value ? colors.primary : colors.onBackgroundLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.categories.incomeCountsTitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
