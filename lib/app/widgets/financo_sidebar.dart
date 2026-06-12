import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/sidebar_brand_row.dart';
import 'package:financo/app/widgets/sidebar_date_scope.dart';
import 'package:financo/app/widgets/sidebar_nav_item.dart';
import 'package:financo/app/widgets/sidebar_profile_tile.dart';
import 'package:financo/app/widgets/sidebar_sub_nav_item.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/auth/presentation/bloc/auth_state.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

const _collapsedWidth = 80.0;
const _expandedWidth = 240.0;
const _animDuration = Duration(milliseconds: 240);
const Curve _animCurve = Curves.easeOutCubic;

/// Web/tablet navigation rail. Three vertical zones, separated by spacing
/// (not dividers): brand + collapse toggle, date scope picker, nav items;
/// then a profile tile pinned at the bottom. Active item carries a left
/// accent bar for the modern Linear/Notion vibe.
class FinancoSidebar extends StatefulWidget {
  const FinancoSidebar({super.key});

  @override
  State<FinancoSidebar> createState() => _FinancoSidebarState();
}

class _FinancoSidebarState extends State<FinancoSidebar> {
  bool _expanded = true;

  void _toggle() {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final location = GoRouterState.of(context).matchedLocation;
    final dateFilter = context.watch<DateFilterCubit>().state;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final isDashboardSection =
        location == AppRoutes.dashboard ||
        location.startsWith(AppRoutes.payablesReceivables) ||
        location.startsWith(AppRoutes.paidAndReceived) ||
        location.startsWith(AppRoutes.payables) ||
        location.startsWith(AppRoutes.receivables) ||
        location.startsWith(AppRoutes.paidAccounts) ||
        location.startsWith(AppRoutes.receivedAccounts);

    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      width: _expanded ? _expandedWidth : _collapsedWidth,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(
            color: colors.surfaceVariant.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SidebarBrandRow(
                expanded: _expanded,
                onNavigateHome: () => context.go(AppRoutes.dashboard),
                onToggle: _toggle,
              ),
              const SizedBox(height: 24),
              SidebarDateScope(
                year: dateFilter.year,
                month: dateFilter.month,
                expanded: _expanded,
                onPrevious: () =>
                    context.read<DateFilterCubit>().previousMonth(),
                onNext: () => context.read<DateFilterCubit>().nextMonth(),
              ),
              const SizedBox(height: 24),
              SidebarNavItem(
                icon: FontAwesomeIcons.house,
                expanded: _expanded,
                label: t.nav.dashboard,
                onTap: () => context.go(AppRoutes.dashboard),
                isActive: isDashboardSection,
              ),
              SidebarSubNavItem(
                icon: FontAwesomeIcons.receipt,
                expanded: _expanded,
                label: t.nav.payablesReceivables,
                onTap: () => context.go(AppRoutes.payablesReceivables),
                isActive:
                    location.startsWith(AppRoutes.payablesReceivables) ||
                    location.startsWith(AppRoutes.payables) ||
                    location.startsWith(AppRoutes.receivables),
              ),
              SidebarSubNavItem(
                icon: FontAwesomeIcons.circleCheck,
                expanded: _expanded,
                label: t.nav.paidAndReceived,
                onTap: () => context.go(AppRoutes.paidAndReceived),
                isActive:
                    location.startsWith(AppRoutes.paidAndReceived) ||
                    location.startsWith(AppRoutes.paidAccounts) ||
                    location.startsWith(AppRoutes.receivedAccounts),
              ),
              SidebarNavItem(
                icon: FontAwesomeIcons.chartPie,
                expanded: _expanded,
                label: t.nav.investments,
                onTap: () => context.go(AppRoutes.investments),
                isActive: location.startsWith(AppRoutes.investments),
              ),
              SidebarNavItem(
                icon: FontAwesomeIcons.bullseye,
                expanded: _expanded,
                label: t.nav.planning,
                onTap: () => context.go(AppRoutes.planning),
                // Planning stays active for its own sub-tabs only; payables
                // now live under Dashboard.
                isActive:
                    location.startsWith(AppRoutes.planning) ||
                    location.startsWith(AppRoutes.budgets) ||
                    location.startsWith(AppRoutes.fiftyThirtyTwenty),
              ),
              SidebarNavItem(
                icon: FontAwesomeIcons.wandMagicSparkles,
                expanded: _expanded,
                label: t.nav.chat,
                onTap: () => context.go(AppRoutes.chat),
                isActive: location == AppRoutes.chat,
              ),
              const Spacer(),
              SidebarProfileTile(
                expanded: _expanded,
                user: user,
                isActive: location == AppRoutes.profile,
                onTap: () => context.go(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
