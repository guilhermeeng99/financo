import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/investing/domain/entities/institution.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';

/// Horizontal institution filter chips (an "All" chip plus one per institution
/// holding value). [selected] is null for "All"; [onSelect] passes the picked
/// institution id (or null).
class OverviewInstitutionFilter extends StatelessWidget {
  const OverviewInstitutionFilter({
    required this.institutionIds,
    required this.institutionsById,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<String> institutionIds;
  final Map<String, Institution> institutionsById;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _FilterChip(
            label: t.investing.overview.filterAll,
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final id in institutionIds) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: institutionsById[id]?.name ?? id,
              selected: selected == id,
              onTap: () => onSelect(id),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary.withValues(alpha: 0.14) : colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: selected ? colors.primary : colors.onBackgroundLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
