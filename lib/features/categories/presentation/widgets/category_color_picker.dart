import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/category_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Single-row chooser for the category accent color. Lets the user override
/// the auto-assigned palette entry — a small but expected affordance for
/// any "create category" flow in modern fintech apps.
class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: CategoryColors.palette.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final value = CategoryColors.palette[i];
          return _Swatch(
            color: Color(value),
            isSelected: value == selected,
            onTap: () => onChanged(value),
          );
        },
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: AnimatedScale(
            scale: isSelected ? 1 : 0.85,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? context.appColors.surface
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
