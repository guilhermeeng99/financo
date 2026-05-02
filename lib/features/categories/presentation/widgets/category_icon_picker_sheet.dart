import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/category_icon_catalog.dart';
import 'package:financo/features/categories/domain/category_icon_option.dart';
import 'package:financo/features/categories/domain/category_icon_search.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Opens the icon picker as a draggable bottom sheet.
///
/// Returns the chosen icon's code point (`int`), or `null` if the user
/// dismissed the sheet without selecting. The current selection is
/// passed in so the sheet can highlight it.
Future<int?> showCategoryIconPicker({
  required BuildContext context,
  required int selectedIcon,
  required int color,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        _CategoryIconPickerSheet(selectedIcon: selectedIcon, color: color),
  );
}

class _CategoryIconPickerSheet extends StatefulWidget {
  const _CategoryIconPickerSheet({
    required this.selectedIcon,
    required this.color,
  });

  final int selectedIcon;
  final int color;

  @override
  State<_CategoryIconPickerSheet> createState() =>
      _CategoryIconPickerSheetState();
}

class _CategoryIconPickerSheetState extends State<_CategoryIconPickerSheet> {
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filtered = searchCategoryIcons(_query, categoryIconCatalog);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _DragHandle(color: colors.onBackgroundLight),
            _Header(label: t.categories.selectIcon),
            _SearchField(
              controller: _queryController,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyResults()
                  : _IconGrid(
                      options: filtered,
                      selectedIcon: widget.selectedIcon,
                      color: widget.color,
                      scrollController: scrollController,
                      onTap: (code) => Navigator.pop(context, code),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.appColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: t.categories.iconSearchHint,
          prefixIcon: SizedBox(
            width: 44,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 14,
                color: colors.onBackgroundLight,
              ),
            ),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 14,
                  color: colors.onBackgroundLight,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              );
            },
          ),
          filled: true,
          fillColor: colors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _IconGrid extends StatelessWidget {
  const _IconGrid({
    required this.options,
    required this.selectedIcon,
    required this.color,
    required this.scrollController,
    required this.onTap,
  });

  final List<CategoryIconOption> options;
  final int selectedIcon;
  final int color;
  final ScrollController scrollController;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tint = Color(color);
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: options.length,
      itemBuilder: (_, i) {
        final opt = options[i];
        final isSelected = opt.codePoint == selectedIcon;
        return _IconCell(
          icon: opt.icon,
          tint: tint,
          isSelected: isSelected,
          onTap: () => onTap(opt.codePoint),
        );
      },
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.icon,
    required this.tint,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
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
                icon,
                color: isSelected ? Colors.white : colors.onBackgroundLight,
                size: 22,
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

class _EmptyResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 24,
              color: colors.onBackgroundLight,
            ),
            const SizedBox(height: 12),
            Text(
              t.categories.iconSearchNoResults,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackgroundLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
