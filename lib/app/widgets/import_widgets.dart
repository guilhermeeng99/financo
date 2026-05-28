import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widgets shared by the CSV import-preview pages (transactions, accounts,
/// categories). The pages differ only in their state type and strings, so the
/// chrome lives here and each page passes in its own copy.

/// Full-screen modal shown while an import runs: title, progress bar, and a
/// "X of Y · NN%" counter row. [progress] is 0..1.
class ImportProgressOverlay extends StatelessWidget {
  const ImportProgressOverlay({
    required this.title,
    required this.counterLabel,
    required this.progress,
    super.key,
  });

  final String title;
  final String counterLabel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      counterLabel,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular red trash button used to drop a row from an import preview.
class ImportRemoveButton extends StatelessWidget {
  const ImportRemoveButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.error.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.trash,
              size: 13,
              color: colors.error,
            ),
          ),
        ),
      ),
    );
  }
}

/// Centred placeholder for an import tab that has nothing to show.
class ImportEmptyTab extends StatelessWidget {
  const ImportEmptyTab({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.appColors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}

/// Tappable labelled-value row used inside an import-preview tile to surface
/// an editable field (account, category, type, …).
///
/// Shows [icon] + [label] above [value] with a trailing chevron, calling
/// [onTap] when pressed. Set [isPlaceholder] to render [value] in the muted
/// "nothing picked yet" colour.
///
/// ```dart
/// ImportPickerRow(
///   icon: FontAwesomeIcons.tag,
///   label: t.transactions.category,
///   value: row.categoryName ?? t.general.none,
///   isPlaceholder: row.categoryName == null,
///   onTap: () => _pickCategory(row),
/// )
/// ```
class ImportPickerRow extends StatelessWidget {
  const ImportPickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isPlaceholder = false,
    super.key,
  });

  final FaIconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              FaIcon(icon, size: 14, color: colors.onBackgroundLight),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isPlaceholder
                            ? colors.onBackgroundLight
                            : colors.onBackground,
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
