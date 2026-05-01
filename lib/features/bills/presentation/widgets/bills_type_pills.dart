import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Visual filter for the bills list: all / payable / receivable.
/// Decoupled from the data layer — the page filters in-memory because
/// both result sets are small and already cached.
enum BillsTypeFilter { all, payable, receivable }

class BillsTypePills extends StatelessWidget {
  const BillsTypePills({
    required this.selected,
    required this.onChanged,
    required this.labels,
    super.key,
  });

  final BillsTypeFilter selected;
  final ValueChanged<BillsTypeFilter> onChanged;

  /// (all, payable, receivable) localized labels — passed in so this widget
  /// stays free of i18n imports and stays trivially testable.
  final ({String all, String payable, String receivable}) labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Pill(
            label: labels.all,
            isSelected: selected == BillsTypeFilter.all,
            onTap: () => onChanged(BillsTypeFilter.all),
          ),
          const SizedBox(width: 8),
          _Pill(
            label: labels.payable,
            isSelected: selected == BillsTypeFilter.payable,
            onTap: () => onChanged(BillsTypeFilter.payable),
          ),
          const SizedBox(width: 8),
          _Pill(
            label: labels.receivable,
            isSelected: selected == BillsTypeFilter.receivable,
            onTap: () => onChanged(BillsTypeFilter.receivable),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? colors.primary : colors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
