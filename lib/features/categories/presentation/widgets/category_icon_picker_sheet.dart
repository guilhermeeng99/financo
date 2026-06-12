import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/app/widgets/financo_search_field.dart';
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
    final filtered = searchCategoryIcons(_query, categoryIconCatalog);
    return FinancoPickerSheet(
      title: t.categories.selectIcon,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      header: [
        FinancoSearchField(
          controller: _queryController,
          onChanged: (v) => setState(() => _query = v),
          hintText: t.categories.iconSearchHint,
        ),
        const SizedBox(height: 8),
      ],
      bodyBuilder: (scrollController) {
        if (filtered.isEmpty) return _EmptyResults();
        return _IconGrid(
          options: filtered,
          selectedIcon: widget.selectedIcon,
          color: widget.color,
          scrollController: scrollController,
          onTap: (code) => Navigator.pop(context, code),
        );
      },
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
