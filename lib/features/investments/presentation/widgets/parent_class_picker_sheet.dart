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
    builder: (sheetContext) {
      final colors = sheetContext.appColors;
      return Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onBackgroundLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.investments.pickParentClass,
                    style: sheetContext.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (roots.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Text(
                    t.investments.parentPickerEmpty,
                    style: sheetContext.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    children: [
                      // "No parent" row — promotes the form to root.
                      Material(
                        color: selectedId == null
                            ? colors.primary.withValues(alpha: 0.12)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                          trailing: selectedId == null
                              ? FaIcon(
                                  FontAwesomeIcons.check,
                                  size: 14,
                                  color: colors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(sheetContext)
                              .pop(const ParentPickResult(null)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final root in roots) ...[
                        Material(
                          color: root.id == selectedId
                              ? colors.primary.withValues(alpha: 0.12)
                              : colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: _ParentAvatar(
                              icon: root.icon,
                              color: root.color,
                            ),
                            title: Text(root.name),
                            subtitle: Text(
                              '${t.investments.targetShort}: '
                              '${root.targetPercent.toStringAsFixed(0)}%',
                            ),
                            trailing: root.id == selectedId
                                ? FaIcon(
                                    FontAwesomeIcons.check,
                                    size: 14,
                                    color: colors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(sheetContext)
                                .pop(ParentPickResult(root)),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
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
