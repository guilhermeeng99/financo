import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/nav_bills_badge.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Mobile AppBar shown on the dashboard. Compact month-stepper centered in
/// the bar — blends with the scaffold background, no shadow.
class FinancoMobileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FinancoMobileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final dateFilter = context.watch<DateFilterCubit>().state;
    final colors = context.appColors;
    final label = formatMonthYear(
      DateTime(dateFilter.year, dateFilter.month),
    );

    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MonthStepperButton(
              icon: FontAwesomeIcons.chevronLeft,
              onTap: () => context.read<DateFilterCubit>().previousMonth(),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            _MonthStepperButton(
              icon: FontAwesomeIcons.chevronRight,
              onTap: () => context.read<DateFilterCubit>().nextMonth(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthStepperButton extends StatelessWidget {
  const _MonthStepperButton({required this.icon, required this.onTap});

  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FaIcon(
          icon,
          size: 12,
          color: context.appColors.onBackgroundLight,
        ),
      ),
    );
  }
}

/// Floating pill-shaped bottom navigation. The active item expands into a
/// labeled pill while inactive items stay as compact icons — same trick
/// modern fintech / messaging apps use to keep a clear "you are here"
/// affordance without sacrificing minimalism.
class FinancoBottomBar extends StatelessWidget {
  const FinancoBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final colors = context.appColors;
    final isDark = context.isDarkMode;

    final currentIndex = _resolveCurrentIndex(location);

    void onTap(int i) {
      if (i == currentIndex) return;
      unawaited(HapticFeedback.selectionClick());
      switch (i) {
        case 0:
          context.go(AppRoutes.dashboard);
        case 1:
          context.go(AppRoutes.bills);
        case 2:
          context.go(AppRoutes.budgets);
        case 3:
          context.go(AppRoutes.chat);
        case 4:
          context.go(AppRoutes.profile);
      }
    }

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: colors.surfaceVariant,
            width: 0.5,
          ),
          boxShadow: isDark
              ? null
              : [
                  // Single soft shadow — the brief calls for "subtle depth,
                  // not heavy shadows" so we drop the previous double-stack.
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: FontAwesomeIcons.house,
              label: t.nav.dashboard,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: FontAwesomeIcons.fileInvoiceDollar,
              label: t.nav.bills,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
              iconWrapper: (icon) => NavBillsBadge(child: icon),
            ),
            _NavItem(
              icon: FontAwesomeIcons.bullseye,
              label: t.nav.budgets,
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: FontAwesomeIcons.wandMagicSparkles,
              label: t.nav.chat,
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: FontAwesomeIcons.user,
              label: t.nav.profile,
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }

  static int _resolveCurrentIndex(String location) {
    if (location.startsWith(AppRoutes.bills)) return 1;
    if (location.startsWith(AppRoutes.budgets)) return 2;
    if (location.startsWith(AppRoutes.chat)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.iconWrapper,
  });

  final FaIconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  /// Optional decorator applied to the rendered icon — used to overlay
  /// adornments like a count badge without coupling this widget to the
  /// specific feature that needs them.
  final Widget Function(Widget icon)? iconWrapper;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = isActive ? colors.primary : colors.onBackgroundLight;
    final iconWidget = FaIcon(icon, size: 16, color: foreground);
    final wrappedIcon = iconWrapper?.call(iconWidget) ?? iconWidget;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 16 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              wrappedIcon,
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  widthFactor: isActive ? 1 : 0,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
