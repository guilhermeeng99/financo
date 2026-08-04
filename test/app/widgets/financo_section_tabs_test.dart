import 'package:financo/app/routes/app_routes.dart';
import 'package:financo/app/widgets/financo_section_tabs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<String> routesFor(String location) =>
      sectionTabsFor(location).map((tab) => tab.route).toList();

  String? activeRouteAt(String location) {
    final tabs = sectionTabsFor(location);
    final index = activeSectionTabIndex(tabs, location);
    return index == -1 ? null : tabs[index].route;
  }

  group('sectionTabsFor', () {
    test('offers every investing destination the sidebar does', () {
      // Regression: mobile has no sidebar, so four of these five were
      // unreachable by touch — only by typing the URL.
      expect(routesFor(AppRoutes.investingOverview), [
        AppRoutes.investingOverview,
        AppRoutes.investingAllocation,
        AppRoutes.investingTransactions,
        AppRoutes.assets,
        AppRoutes.institutions,
      ]);
    });

    test('offers the dashboard group from any of its members', () {
      const expected = [
        AppRoutes.dashboard,
        AppRoutes.payablesReceivables,
        AppRoutes.paidAndReceived,
      ];
      expect(routesFor(AppRoutes.dashboard), expected);
      expect(routesFor(AppRoutes.payablesReceivables), expected);
      expect(routesFor(AppRoutes.paidAndReceived), expected);
      expect(routesFor(AppRoutes.receivables), expected);
    });

    test('stays empty outside a group', () {
      expect(sectionTabsFor(AppRoutes.chat), isEmpty);
      expect(sectionTabsFor(AppRoutes.planning), isEmpty);
      expect(sectionTabsFor(AppRoutes.profile), isEmpty);
      expect(sectionTabsFor(AppRoutes.categories), isEmpty);
    });
  });

  group('activeSectionTabIndex', () {
    test('highlights the destination being viewed', () {
      expect(activeRouteAt(AppRoutes.assets), AppRoutes.assets);
      expect(activeRouteAt(AppRoutes.institutions), AppRoutes.institutions);
      expect(
        activeRouteAt(AppRoutes.investingAllocation),
        AppRoutes.investingAllocation,
      );
    });

    test('keeps the parent lit on a nested route', () {
      expect(activeRouteAt('${AppRoutes.assets}/import'), AppRoutes.assets);
      expect(activeRouteAt(AppRoutes.payables), AppRoutes.payablesReceivables);
      expect(
        activeRouteAt(AppRoutes.receivedAccounts),
        AppRoutes.paidAndReceived,
      );
    });

    test('matches the dashboard exactly, never as a prefix', () {
      // '/' prefixes every route in the app, so a plain startsWith would
      // light the Dashboard pill on payables and paid-and-received too.
      expect(activeRouteAt(AppRoutes.dashboard), AppRoutes.dashboard);
      expect(
        activeRouteAt(AppRoutes.payablesReceivables),
        AppRoutes.payablesReceivables,
      );
      expect(
        activeRouteAt(AppRoutes.paidAndReceived),
        AppRoutes.paidAndReceived,
      );
    });
  });
}
