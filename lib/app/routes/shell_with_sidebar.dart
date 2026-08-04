import 'package:financo/app/widgets/financo_mobile_nav.dart';
import 'package:financo/app/widgets/financo_section_tabs.dart';
import 'package:financo/app/widgets/financo_sidebar.dart';
import 'package:financo/app/widgets/section_tabs_scope.dart';
import 'package:financo/app/widgets/sub_page_scope.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell chrome around every tab page: a navigation rail on tablet/desktop,
/// a floating bottom bar on mobile. Extracted from `app_router.dart`, which
/// was 721 lines — over the project's 400-600 ceiling — and mixed this pure
/// layout widget in with the route tree it has no dependency on.
class ShellWithSidebar extends StatefulWidget {
  const ShellWithSidebar({required this.child, super.key});

  final Widget child;

  static const double _mobileBreakpoint = 600;

  @override
  State<ShellWithSidebar> createState() => ShellWithSidebarState();
}

class ShellWithSidebarState extends State<ShellWithSidebar> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (router != _router) {
      _router?.routerDelegate.removeListener(_onRouteChange);
      _router = router;
      _router!.routerDelegate.addListener(_onRouteChange);
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }

  void _onRouteChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < ShellWithSidebar._mobileBreakpoint;

    if (!isMobile) publishSectionTabs(const []);

    if (isMobile) {
      return ValueListenableBuilder<int>(
        valueListenable: subPageDepthListenable,
        builder: (context, depth, _) {
          final isOnSubPage = depth > 0;
          final showBottomBar = !isOnSubPage;

          // The section strip is the mobile stand-in for the sidebar's
          // collapsible sub-menus, so it follows the same rule as the bottom
          // bar: primary tabs only, never over a pushed sub-page.
          publishSectionTabs(
            isOnSubPage
                ? const []
                : sectionTabsFor(GoRouterState.of(context).matchedLocation),
          );

          return Scaffold(
            // Lets scrollable content flow behind the floating bottom bar
            // so it visually "lifts" off the page instead of clipping the
            // body.
            extendBody: true,
            body: widget.child,
            bottomNavigationBar: showBottomBar
                ? const FinancoBottomBar()
                : null,
          );
        },
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const FinancoSidebar(),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
