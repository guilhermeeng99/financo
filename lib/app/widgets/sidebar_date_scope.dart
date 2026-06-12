import 'dart:async';

import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// Month/year scope stepper shown in the sidebar. Expanded: a horizontal
/// "‹ month year ›" row. Collapsed: a vertical stack with up/down
/// chevrons. [onPrevious]/[onNext] step the global date filter.
class SidebarDateScope extends StatelessWidget {
  const SidebarDateScope({
    required this.year,
    required this.month,
    required this.expanded,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final int year;
  final int month;
  final bool expanded;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: expanded
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
          : const EdgeInsets.symmetric(vertical: 6),
      child: expanded ? _expandedView(context) : _collapsedView(context),
    );
  }

  Widget _expandedView(BuildContext context) {
    final colors = context.appColors;
    final label = formatMonthYear(DateTime(year, month));
    return Row(
      children: [
        _StepperBtn(icon: FontAwesomeIcons.chevronLeft, onTap: onPrevious),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _StepperBtn(icon: FontAwesomeIcons.chevronRight, onTap: onNext),
      ],
    );
  }

  Widget _collapsedView(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        _StepperBtn(icon: FontAwesomeIcons.chevronUp, onTap: onPrevious),
        const SizedBox(height: 4),
        Text(
          _shortMonth(month),
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$year',
          style: context.textTheme.labelSmall?.copyWith(
            color: colors.onBackgroundLight,
            fontSize: 10,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        _StepperBtn(icon: FontAwesomeIcons.chevronDown, onTap: onNext),
      ],
    );
  }

  static String _shortMonth(int m) {
    // Locale-aware month abbreviation so the sidebar reads "fev" / "out"
    // in pt-BR instead of the hardcoded English list it used to ship.
    final locale = LocaleSettings.currentLocale.languageTag;
    return DateFormat.MMM(locale).format(DateTime(2000, m));
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});

  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: FaIcon(icon, size: 11, color: colors.onBackgroundLight),
      ),
    );
  }
}
