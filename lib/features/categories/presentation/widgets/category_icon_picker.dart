import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/categories/presentation/widgets/category_icon_picker_sheet.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Inline tile that previews the currently selected icon and opens
/// [showCategoryIconPicker] on tap. Replaces the old fixed 30-icon grid
/// — the catalog is now too large to render inline, and the bottom-sheet
/// picker also gives us a search field.
class CategoryIconPickerLauncher extends StatelessWidget {
  const CategoryIconPickerLauncher({
    required this.selectedIcon,
    required this.color,
    required this.onChanged,
    super.key,
  });

  final int selectedIcon;
  final int color;
  final ValueChanged<int> onChanged;

  Future<void> _open(BuildContext context) async {
    final picked = await showCategoryIconPicker(
      context: context,
      selectedIcon: selectedIcon,
      color: color,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = Color(color);
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    materialIconFor(selectedIcon),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.categories.chooseIcon,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: colors.onBackgroundLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
