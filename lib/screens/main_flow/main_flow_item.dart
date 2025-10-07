import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_routes.dart';
import 'package:financo/screens/main_flow/main_flow_bloc.dart';
import 'package:financo/screens/main_flow/main_flow_model.dart';

class TopBarItem {
  const TopBarItem({required this.onTap, required this.icon});

  final IconData icon;
  final void Function() onTap;
}

MainFlowTopBarController get mainFlowTopBarController =>
    Modular.get<MainFlowTopBarController>();

class MainFlowTopBarController {
  TopBarItem get sideBarItem => TopBarItem(
    onTap: mainFlowTopBarModel.onTapSideBar,
    icon: Icons.menu,
  );
  TopBarItem get overviewItem => TopBarItem(
    onTap: mainFlowTopBarModel.onTapOverview,
    icon: Icons.pie_chart,
  );
  TopBarItem get profileItem => TopBarItem(
    onTap: mainFlowTopBarModel.onTapProfile,
    icon: Icons.account_circle,
  );
}

@immutable
class SideBarItem {
  const SideBarItem({
    required this.title,
    this.icon,
    this.route,
    this.children = const [],
    this.level = 0,
  });

  final String Function(BuildContext) title;
  final IconData? icon;
  final String? route;
  final List<SideBarItem> children;
  final int level;

  void Function() get onTap => isParent
      ? () => mainFlowBloc.toggleSideBarItem(this)
      : () => mainFlowBloc.selectSideBarItem(this);

  bool get isParent => children.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SideBarItem &&
        other.route == route &&
        other.level == level &&
        other.icon == icon;
  }

  @override
  int get hashCode => Object.hash(route, level, icon);
}

MainFlowSideBarController get mainFlowSideBarController =>
    Modular.get<MainFlowSideBarController>();

class MainFlowSideBarController {
  SideBarItem get financialMovementItem => SideBarItem(
    title: (context) => context.t.navigation.financial_movement,
    icon: Icons.paid,
    children: [releasesItem, pastReleasesItem, futureReleasesItem],
  );

  SideBarItem get releasesItem => SideBarItem(
    title: (context) => context.t.navigation.releases,
    icon: Icons.timeline,
    route: ro.mainFlow.financialMovement.releases.route,
    level: 1,
  );

  SideBarItem get pastReleasesItem => SideBarItem(
    title: (context) => context.t.navigation.paid_and_received,
    icon: Icons.graphic_eq,
    route:
        '${ro.mainFlow.financialMovement.pastAndFutureReleases.route}?type=past',
    level: 1,
  );

  SideBarItem get futureReleasesItem => SideBarItem(
    title: (context) => context.t.navigation.to_pay_and_to_receive,
    icon: Icons.scatter_plot,
    route:
        '${ro.mainFlow.financialMovement.pastAndFutureReleases.route}?type=future',
    level: 1,
  );

  SideBarItem get accountStatementItem => SideBarItem(
    title: (context) => context.t.navigation.account_statement,
    icon: Icons.account_balance,
    route: ro.mainFlow.accountStatement.route,
  );

  SideBarItem get creditCardItem => SideBarItem(
    title: (context) => context.t.navigation.credit_card,
    icon: Icons.credit_card,
    route: ro.mainFlow.creditCard.route,
  );

  SideBarItem get registrationsItem => SideBarItem(
    title: (context) => context.t.navigation.register,
    icon: Icons.label,
    children: [categoriesItem, accountsItem],
  );

  SideBarItem get categoriesItem => SideBarItem(
    title: (context) => context.t.navigation.categories,
    icon: Icons.sell,
    route: ro.mainFlow.register.categories.route,
    level: 1,
  );

  SideBarItem get accountsItem => SideBarItem(
    title: (context) => context.t.navigation.accounts,
    icon: Icons.wallet,
    route: ro.mainFlow.register.accounts.route,
    level: 1,
  );

  List<SideBarItem> get sideBarItems => [
    financialMovementItem,
    accountStatementItem,
    creditCardItem,
    registrationsItem,
  ];

  List<SideBarItem> get flattenedItems {
    final flattened = <SideBarItem>[];

    for (final item in sideBarItems) {
      flattened.add(item);
      if (item.isParent && mainFlowBloc.isItemExpanded(item)) {
        flattened.addAll(item.children);
      }
    }

    return flattened;
  }
}
