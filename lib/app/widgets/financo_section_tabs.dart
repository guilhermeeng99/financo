import 'dart:async';

import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

/// Height the app bar must reserve when a section strip is showing.
const double kSectionTabsHeight = 46;

/// One destination inside a navigation *group* — the mobile counterpart of a
/// `SidebarSubNavItem`.
@immutable
class SectionTab {
  const SectionTab({
    required this.icon,
    required this.label,
    required this.route,
    required this.activePrefixes,
  });

  final FaIconData icon;
  final String label;
  final String route;

  /// Locations that light this tab up. Prefixes, so `/investing/assets` also
  /// covers `/investing/assets/import`.
  final List<String> activePrefixes;

  bool matches(String location) =>
      activePrefixes.any((prefix) => location.startsWith(prefix));
}

/// The groups the desktop sidebar renders as collapsible sub-menus. Mobile has
/// no sidebar, so without this strip four of the five investing pages and both
/// payables pages were unreachable by touch — only by typing the URL.
///
/// Returns an empty list for locations outside a group; the caller then
/// renders nothing and reserves no height.
List<SectionTab> sectionTabsFor(String location) {
  if (location.startsWith('/investing')) return _investingTabs();
  if (_dashboardGroup.any((prefix) => location.startsWith(prefix)) ||
      location == AppRoutes.dashboard) {
    return _dashboardTabs();
  }
  return const [];
}

const List<String> _dashboardGroup = [
  AppRoutes.payablesReceivables,
  AppRoutes.paidAndReceived,
  AppRoutes.payables,
  AppRoutes.receivables,
  AppRoutes.paidAccounts,
  AppRoutes.receivedAccounts,
];

List<SectionTab> _dashboardTabs() => [
  SectionTab(
    icon: FontAwesomeIcons.house,
    label: t.nav.dashboard,
    route: AppRoutes.dashboard,
    // Exact match only: every route starts with '/'.
    activePrefixes: const [],
  ),
  SectionTab(
    icon: FontAwesomeIcons.receipt,
    label: t.nav.payablesReceivables,
    route: AppRoutes.payablesReceivables,
    activePrefixes: const [
      AppRoutes.payablesReceivables,
      AppRoutes.payables,
      AppRoutes.receivables,
    ],
  ),
  SectionTab(
    icon: FontAwesomeIcons.circleCheck,
    label: t.nav.paidAndReceived,
    route: AppRoutes.paidAndReceived,
    activePrefixes: const [
      AppRoutes.paidAndReceived,
      AppRoutes.paidAccounts,
      AppRoutes.receivedAccounts,
    ],
  ),
];

/// Overview leads because it is where the bottom bar's Investing tab lands —
/// the active tab is then visible without scrolling the strip. The sidebar
/// orders the same destinations differently; that is deliberate.
List<SectionTab> _investingTabs() => [
  SectionTab(
    icon: FontAwesomeIcons.chartPie,
    label: t.investing.overview.title,
    route: AppRoutes.investingOverview,
    activePrefixes: const [AppRoutes.investingOverview],
  ),
  SectionTab(
    icon: FontAwesomeIcons.scaleBalanced,
    label: t.investing.allocation.title,
    route: AppRoutes.investingAllocation,
    activePrefixes: const [AppRoutes.investingAllocation],
  ),
  SectionTab(
    icon: FontAwesomeIcons.rightLeft,
    label: t.investing.transactions.title,
    route: AppRoutes.investingTransactions,
    activePrefixes: const [AppRoutes.investingTransactions],
  ),
  SectionTab(
    icon: FontAwesomeIcons.coins,
    label: t.investing.assets.title,
    route: AppRoutes.assets,
    activePrefixes: const [AppRoutes.assets],
  ),
  SectionTab(
    icon: FontAwesomeIcons.buildingColumns,
    label: t.investing.institutions.title,
    route: AppRoutes.institutions,
    activePrefixes: const [AppRoutes.institutions],
  ),
];

/// Resolves the active tab. A tab with no prefixes matches the location
/// exactly — `/` would otherwise prefix-match every route in the app.
int activeSectionTabIndex(List<SectionTab> tabs, String location) {
  final byPrefix = tabs.indexWhere(
    (tab) => tab.activePrefixes.isNotEmpty && tab.matches(location),
  );
  if (byPrefix != -1) return byPrefix;
  return tabs.indexWhere((tab) => tab.route == location);
}

/// Horizontally scrollable pill strip that switches between the sections of
/// the current group. Rendered under the large title by
/// `FinancoLargeAppBar`; pages do not build it themselves.
class FinancoSectionTabs extends StatefulWidget {
  const FinancoSectionTabs({required this.tabs, super.key});

  final List<SectionTab> tabs;

  @override
  State<FinancoSectionTabs> createState() => _FinancoSectionTabsState();
}

class _FinancoSectionTabsState extends State<FinancoSectionTabs> {
  final GlobalKey _activeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _revealActiveTab();
  }

  @override
  void didUpdateWidget(FinancoSectionTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    _revealActiveTab();
  }

  /// Five investing pills overflow a phone's width, so landing on one of the
  /// trailing destinations would show a strip with no visible active pill —
  /// the user could not tell where they were.
  void _revealActiveTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _activeKey.currentContext;
      if (target == null) return;
      unawaited(
        Scrollable.ensureVisible(
          target,
          alignment: 0.5,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = activeSectionTabIndex(widget.tabs, location);

    return SizedBox(
      height: kSectionTabsHeight,
      // Deliberately not a ListView: its lazy builder skips off-screen
      // children, so the active pill — the one we need to scroll to — would
      // have no element and no context for `ensureVisible`. A handful of
      // pills costs nothing to build eagerly.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Row(
          children: [
            for (var index = 0; index < widget.tabs.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              _SectionTabPill(
                key: index == activeIndex ? _activeKey : null,
                tab: widget.tabs[index],
                isActive: index == activeIndex,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTabPill extends StatelessWidget {
  const _SectionTabPill({
    required this.tab,
    required this.isActive,
    super.key,
  });

  final SectionTab tab;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = isActive ? colors.primary : colors.onBackgroundLight;
    return Material(
      color: isActive
          ? colors.primary.withValues(alpha: 0.12)
          : colors.surfaceVariant.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isActive ? null : () => context.go(tab.route),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(tab.icon, size: 12, color: foreground),
              const SizedBox(width: 8),
              Text(
                tab.label,
                maxLines: 1,
                softWrap: false,
                style: context.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
