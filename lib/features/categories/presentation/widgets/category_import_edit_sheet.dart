import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/app/widgets/financo_text_field.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/categories/domain/usecases/import_categories_csv_usecase.dart';
import 'package:financo/features/categories/presentation/widgets/category_color_picker.dart';
import 'package:financo/features/categories/presentation/widgets/category_icon_picker.dart';
import 'package:financo/features/categories/presentation/widgets/category_preview_tile.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Bottom sheet to edit a single categories-import preview item: name,
/// icon, color. Pops with the edited [CategoryImportPreviewItem], or
/// `null` when dismissed. The type/parent relationship is locked here —
/// those are decided by the CSV shape and editing them mid-preview would
/// create cross-tab confusion.
///
/// ```dart
/// final edited = await showModalBottomSheet<CategoryImportPreviewItem>(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => CategoryImportEditSheet(item: item),
/// );
/// ```
class CategoryImportEditSheet extends StatefulWidget {
  const CategoryImportEditSheet({required this.item, super.key});

  final CategoryImportPreviewItem item;

  @override
  State<CategoryImportEditSheet> createState() =>
      _CategoryImportEditSheetState();
}

class _CategoryImportEditSheetState extends State<CategoryImportEditSheet> {
  late final TextEditingController _nameController;
  late int _icon;
  late int _color;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _icon = widget.item.icon;
    _color = widget.item.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      widget.item.copyWith(name: name, icon: _icon, color: _color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onBackgroundLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.categories.importEditTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + viewInsets),
                children: [
                  CategoryPreviewTile(
                    name: _nameController.text.trim().isEmpty
                        ? t.categories.nameHint
                        : _nameController.text.trim(),
                    icon: _icon,
                    color: _color,
                  ),
                  const SizedBox(height: 16),
                  FinancoTextField(
                    controller: _nameController,
                    label: t.categories.name,
                    hintText: t.categories.nameHint,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.categories.selectColor.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onBackgroundLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CategoryColorPicker(
                    selected: _color,
                    onChanged: (c) => setState(() => _color = c),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.categories.selectIcon.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onBackgroundLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CategoryIconPickerLauncher(
                    selectedIcon: _icon,
                    color: _color,
                    onChanged: (i) => setState(() => _icon = i),
                  ),
                ],
              ),
            ),
            FinancoSubmitBar(
              label: t.general.save,
              onSubmit: _save,
              isEnabled: _nameController.text.trim().isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
}
