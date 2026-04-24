import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:financo/gen/i18n/strings.g.dart';
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
            onPressed: () =>
                context.read<DateFilterCubit>().previousMonth(),
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

    return NavigationBar(
      backgroundColor: colors.surface,
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go(AppRoutes.dashboard);
          case 1:
            context.go(AppRoutes.chat);
          case 2:
            context.go(AppRoutes.profile);
        }
      },
      destinations: [
        NavigationDestination(
          icon: const FaIcon(FontAwesomeIcons.house, size: 18),
          label: t.nav.dashboard,
        ),
        NavigationDestination(
          icon: const FaIcon(FontAwesomeIcons.comment, size: 18),
          label: t.nav.chat,
        ),
        NavigationDestination(
          icon: const FaIcon(FontAwesomeIcons.gear, size: 18),
          label: t.nav.profile,
        ),
      ],
    );
  }
}
