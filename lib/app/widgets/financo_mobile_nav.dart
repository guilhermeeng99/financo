import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: colors.surface,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => context.read<DateFilterCubit>().previousMonth(),
            icon: FaIcon(
              FontAwesomeIcons.chevronLeft,
              size: 14,
              color: colors.onBackgroundLight,
            ),
          ),
          Text(
            label,
            style: context.textTheme.titleSmall?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => context.read<DateFilterCubit>().nextMonth(),
            icon: FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: colors.onBackgroundLight,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancoBottomBar extends StatelessWidget {
  const FinancoBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final colors = context.appColors;

    var currentIndex = 0;
    if (location.startsWith(AppRoutes.chat)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.profile)) {
      currentIndex = 2;
    }

    void onTap(int i) {
      switch (i) {
        case 0:
          context.go(AppRoutes.dashboard);
        case 1:
          context.go(AppRoutes.chat);
        case 2:
          context.go(AppRoutes.profile);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Item(
              icon: FontAwesomeIcons.house,
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _Item(
              icon: FontAwesomeIcons.comment,
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _Item(
              icon: FontAwesomeIcons.gear,
              index: 2,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final FaIconData icon;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    final colors = context.appColors;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 18,
            color: isSelected ? colors.primary : colors.onBackgroundLight,
          ),
        ),
      ),
    );
  }
}
