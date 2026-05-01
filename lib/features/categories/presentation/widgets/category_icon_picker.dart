import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _availableIcons = <int>[
  59470, 59473, 58332, 58746, 58715, 58288, 59545, 58714, 59494, 58726,
  58261, 59560, 58818, 58835, 59690, 59502, 58404, 59472, 58286, 58947,
  58810, 58694, 58168, 58123, 58736, 58889, 58392, 59411, 58682, 59588,
];

/// Compact 6-column grid for picking a Material icon. The selected tile
/// fills with the category's color so the user previews the final look
/// while choosing. Color stays fixed to the auto-assigned palette entry.
class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    required this.selectedIcon,
    required this.color,
    required this.onChanged,
    super.key,
  });

  final int selectedIcon;
  final int color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tint = Color(color);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _availableIcons.length,
      itemBuilder: (_, i) {
        final code = _availableIcons[i];
        final isSelected = code == selectedIcon;
        return _IconCell(
          iconCode: code,
          tint: tint,
          isSelected: isSelected,
          onTap: () => onChanged(code),
        );
      },
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.iconCode,
    required this.tint,
    required this.isSelected,
    required this.onTap,
  });

  final int iconCode;
  final Color tint;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: isSelected ? tint : colors.surfaceVariant,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Center(
              child: Icon(
                IconData(iconCode, fontFamily: 'MaterialIcons'),
                color: isSelected ? Colors.white : colors.onBackgroundLight,
                size: 20,
              ),
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.check,
                      size: 8,
                      color: tint,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
