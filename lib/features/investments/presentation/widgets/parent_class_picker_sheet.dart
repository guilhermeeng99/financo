import 'package:financo/app/widgets/financo_picker_sheet.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/dynamic_icon.dart';
import 'package:financo/features/investments/domain/entities/asset_class_entity.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Modal sheet that lets the user pick the parent class for a
/// subclass. Lists only **root** classes (`parentId == null`) — one
/// nesting level is the hard limit. Returns the picked entity, or
/// `null` (sentinel) when the user picks the "no parent" row to
/// promote the subclass back to a root.
Future<ParentPickResult?> showParentClassPickerSheet({
  required BuildContext context,
  required List<AssetClassEntity> classes,
  required String? selectedId,
}) {
  final roots = classes.where((c) => c.parentId == null).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return showModalBottomSheet<ParentPickResult>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => FinancoPickerSheet.fixed(
      title: t.investments.pickParentClass,
      child: roots.isEmpty
          ? const _NoRootsHint()
          : Flexible(
              child: _RootClassList(roots: roots, selectedId: selectedId),
            ),
    ),
  );
}

class _NoRootsHint extends StatelessWidget {
  const _NoRootsHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Text(
        t.investments.parentPickerEmpty,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.appColors.onBackgroundLight,
        ),
      ),
    );
  }
}

class _RootClassList extends StatelessWidget {
  const _RootClassList({required this.roots, required this.selectedId});

  final List<AssetClassEntity> roots;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        // "No parent" row — promotes the form to root.
        _NoneRow(isSelected: selectedId == null),
        const SizedBox(height: 6),
        for (final root in roots) ...[
          _RootRow(root: root, isSelected: root.id == selectedId),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _NoneRow extends StatelessWidget {
  const _NoneRow({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _PickerTile(
      isSelected: isSelected,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.minus,
            size: 12,
            color: colors.onBackgroundLight,
          ),
        ),
      ),
      title: Text(t.investments.parentPickerNone),
      onTap: () => Navigator.of(context).pop(const ParentPickResult(null)),
    );
  }
}

class _RootRow extends StatelessWidget {
  const _RootRow({required this.root, required this.isSelected});

  final AssetClassEntity root;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return _PickerTile(
      isSelected: isSelected,
      leading: _ParentAvatar(icon: root.icon, color: root.color),
      title: Text(root.name),
      subtitle: Text(
        '${t.investments.targetShort}: '
        '${root.targetPercent.toStringAsFixed(0)}%',
      ),
      onTap: () => Navigator.of(context).pop(ParentPickResult(root)),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.isSelected,
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final bool isSelected;
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: isSelected
          ? colors.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: isSelected
            ? FaIcon(
                FontAwesomeIcons.check,
                size: 14,
                color: colors.primary,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _ParentAvatar extends StatelessWidget {
  const _ParentAvatar({required this.icon, required this.color});

  final int icon;
  final int color;

  @override
  Widget build(BuildContext context) {
    final tint = Color(color);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          materialIconFor(icon),
          size: 16,
          color: tint,
        ),
      ),
    );
  }
}

/// Carrier so the sheet's `Navigator.pop` can distinguish "user picked
/// no parent" (a deliberate choice) from "user dismissed the sheet"
/// (no result at all). Outer code unwraps via `.parent`.
class ParentPickResult {
  const ParentPickResult(this.parent);
  final AssetClassEntity? parent;
}
