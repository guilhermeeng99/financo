import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// One option of a [FinancoPillToggle].
class FinancoPillToggleOption<T> {
  const FinancoPillToggleOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final FaIconData? icon;
}

/// Custom 2+ segment pill toggle. Replaces Material's `SegmentedButton`
/// so forms and settings get bigger tap targets, softer corners and a
/// friendlier selected-state animation. Used by the bill form (type,
/// recurrence) and the profile theme selector (light/dark/system).
class FinancoPillToggle<T> extends StatelessWidget {
  const FinancoPillToggle({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.disabled = false,
    super.key,
  });

  final List<FinancoPillToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  /// True when the field is locked (e.g. editing a bill — type/recurrence
  /// are immutable after creation per the spec). Visually muted, taps no-op.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _Segment<T>(
                option: option,
                isSelected: option.value == selected,
                disabled: disabled,
                onTap: () => onChanged(option.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.isSelected,
    required this.disabled,
    required this.onTap,
  });

  final FinancoPillToggleOption<T> option;
  final bool isSelected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = isSelected
        ? colors.onBackground
        : colors.onBackgroundLight;
    return Opacity(
      opacity: disabled && !isSelected ? 0.5 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: disabled ? null : onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 10,
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        FaIcon(option.icon, size: 13, color: foreground),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        option.label,
                        maxLines: 1,
                        softWrap: false,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
