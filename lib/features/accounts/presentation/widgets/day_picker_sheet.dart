import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet that lets the user pick a day-of-month between 1 and
/// 28 (the safe range for credit-card closing/due days). Cleaner than the
/// stock `DropdownButtonFormField` with 28 items.
Future<int?> showDayPickerSheet({
  required BuildContext context,
  required int? selected,
  required String title,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _DayPickerSheet(
      selected: selected,
      title: title,
    ),
  );
}

class _DayPickerSheet extends StatelessWidget {
  const _DayPickerSheet({required this.selected, required this.title});

  final int? selected;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                itemCount: 28,
                itemBuilder: (_, i) {
                  final day = i + 1;
                  final isSelected = day == selected;
                  return _DayButton(
                    day: day,
                    isSelected: isSelected,
                    onTap: () => Navigator.pop(context, day),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: isSelected ? colors.primary : colors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            '$day',
            style: context.textTheme.titleSmall?.copyWith(
              color: isSelected ? Colors.white : colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
