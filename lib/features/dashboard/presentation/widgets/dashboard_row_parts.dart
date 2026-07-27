import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Small building blocks shared by `DashboardAccountRow` and
/// `DashboardInstitutionRow` so the two balance-list rows stay visually
/// identical without hand-syncing copy-pasted widgets.

/// The compact "include in total" checkbox both rows prepend. Sized to sit in
/// the row's tap target without dominating it.
class DashboardIncludeCheckbox extends StatelessWidget {
  const DashboardIncludeCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: 28,
      height: 28,
      child: Checkbox(
        value: value,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        activeColor: colors.primary,
        onChanged: onChanged == null ? null : (_) => onChanged!(),
      ),
    );
  }
}

/// A small rounded pill below the row name, tinted at 14% of [tint]. Used for
/// the account-type tag (checking/savings/credit) and the investment tag.
class DashboardPill extends StatelessWidget {
  const DashboardPill({required this.label, required this.tint, super.key});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: tint,
          fontWeight: FontWeight.w700,
          height: 1,
          fontSize: 10,
        ),
      ),
    );
  }
}
