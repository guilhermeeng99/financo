import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/core/constants/app_constants.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

const _collapsedWidth = 72.0;
const _expandedWidth = 220.0;
const _animDuration = Duration(milliseconds: 200);

class FinancoSidebar extends StatefulWidget {
  const FinancoSidebar({super.key});

  @override
  State<FinancoSidebar> createState() => _FinancoSidebarState();
}

class _FinancoSidebarState extends State<FinancoSidebar> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final location = GoRouterState.of(context).matchedLocation;
    final dateFilter = context.watch<DateFilterCubit>().state;

    return AnimatedContainer(
      duration: _animDuration,
      width: _expanded ? _expandedWidth : _collapsedWidth,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(color: colors.surfaceVariant),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Toggle button
          _SidebarIconButton(
            icon: _expanded ? FontAwesomeIcons.xmark : FontAwesomeIcons.bars,
            expanded: _expanded,
            label: AppConstants.appName,
            onTap: _toggle,
            isActive: false,
            colors: colors,
          ),
          const SizedBox(height: 4),
          // Date selector
          _DateSelector(
            year: dateFilter.year,
            month: dateFilter.month,
            expanded: _expanded,
            onPrevious: () => context.read<DateFilterCubit>().previousMonth(),
            onNext: () => context.read<DateFilterCubit>().nextMonth(),
            colors: colors,
          ),
          const Divider(height: 16),
          // Nav items
          _SidebarIconButton(
            icon: FontAwesomeIcons.house,
            expanded: _expanded,
            label: t.nav.dashboard,
            onTap: () => context.go(AppRoutes.dashboard),
            isActive: location == AppRoutes.dashboard,
            colors: colors,
          ),
          _SidebarIconButton(
            icon: FontAwesomeIcons.fileInvoiceDollar,
            expanded: _expanded,
            label: t.nav.bills,
            onTap: () => context.go(AppRoutes.bills),
            isActive: location.startsWith(AppRoutes.bills),
            colors: colors,
          ),
          _SidebarIconButton(
            icon: FontAwesomeIcons.comment,
            expanded: _expanded,
            label: t.nav.chat,
            onTap: () => context.go(AppRoutes.chat),
            isActive: location == AppRoutes.chat,
            colors: colors,
          ),
          const Spacer(),
          _SidebarIconButton(
            icon: FontAwesomeIcons.gear,
            expanded: _expanded,
            label: t.nav.profile,
            onTap: () => context.go(AppRoutes.profile),
            isActive: location == AppRoutes.profile,
            colors: colors,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SidebarIconButton extends StatelessWidget {
  const _SidebarIconButton({
    required this.icon,
    required this.expanded,
    required this.label,
    required this.onTap,
    required this.isActive,
    required this.colors,
  });

  final FaIconData icon;
  final bool expanded;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final AppColorsData colors;

  @override
  Widget build(BuildContext context) {
    final fg = isActive ? colors.primary : colors.onBackgroundLight;
    final bg = isActive ? colors.primary.withAlpha(25) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Center(
                    child: FaIcon(icon, size: 18, color: fg),
                  ),
                ),
                if (expanded)
                  Expanded(
                    child: Text(
                      label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.year,
    required this.month,
    required this.expanded,
    required this.onPrevious,
    required this.onNext,
    required this.colors,
  });

  final int year;
  final int month;
  final bool expanded;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final AppColorsData colors;

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            _SmallIconBtn(
              icon: FontAwesomeIcons.chevronUp,
              onTap: onPrevious,
              colors: colors,
            ),
            const SizedBox(height: 2),
            Text(
              _shortMonth(month),
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$year',
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackgroundLight,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            _SmallIconBtn(
              icon: FontAwesomeIcons.chevronDown,
              onTap: onNext,
              colors: colors,
            ),
          ],
        ),
      );
    }

    final label = formatMonthYear(DateTime(year, month));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _SmallIconBtn(
            icon: FontAwesomeIcons.chevronLeft,
            onTap: onPrevious,
            colors: colors,
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _SmallIconBtn(
            icon: FontAwesomeIcons.chevronRight,
            onTap: onNext,
            colors: colors,
          ),
        ],
      ),
    );
  }

  String _shortMonth(int m) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[m - 1];
  }
}

class _SmallIconBtn extends StatelessWidget {
  const _SmallIconBtn({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  final FaIconData icon;
  final VoidCallback onTap;
  final AppColorsData colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: FaIcon(icon, size: 12, color: colors.onBackgroundLight),
      ),
    );
  }
}
