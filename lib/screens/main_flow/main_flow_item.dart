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
  final List<TopBarItem> topBarItems = [
    TopBarItem(onTap: mainFlowTopBarModel.onTapSideBar, icon: Icons.menu),
    TopBarItem(onTap: mainFlowTopBarModel.onTapOverview, icon: Icons.pie_chart),
  ];
}

enum SideBarItemType {
  overview,
  financialMovement,
  pastReleases,
  futureReleases,
  accountStatement,
  releases,
  registrations,
  categories,
  accounts,
}

extension SideBarItemTypeExtension on SideBarItemType {
  String? get route {
    switch (this) {
      case SideBarItemType.overview:
        return ro.mainFlow.home.route;
      case SideBarItemType.financialMovement:
        return null;
      case SideBarItemType.futureReleases:
        return '${ro.mainFlow.financialMovement.pastAndFutureReleases.route}?type=future';
      case SideBarItemType.pastReleases:
        return '${ro.mainFlow.financialMovement.pastAndFutureReleases.route}?type=past';
      case SideBarItemType.releases:
        return ro.mainFlow.financialMovement.releases.route;
      case SideBarItemType.accountStatement:
        return ro.mainFlow.financialMovement.accountStatement.route;
      case SideBarItemType.registrations:
        return null;
      case SideBarItemType.categories:
        return ro.mainFlow.register.categories.route;
      case SideBarItemType.accounts:
        return ro.mainFlow.register.accounts.route;
    }
  }

  String title(BuildContext context) {
    switch (this) {
      case SideBarItemType.overview:
        return context.t.navigation.overview;
      case SideBarItemType.financialMovement:
        return context.t.navigation.financial_movement;
      case SideBarItemType.futureReleases:
        return context.t.navigation.to_pay_and_to_receive;
      case SideBarItemType.pastReleases:
        return context.t.navigation.paid_and_received;
      case SideBarItemType.accountStatement:
        return context.t.navigation.account_statement;
      case SideBarItemType.releases:
        return context.t.navigation.releases;
      case SideBarItemType.registrations:
        return context.t.navigation.register;
      case SideBarItemType.categories:
        return context.t.navigation.categories;
      case SideBarItemType.accounts:
        return context.t.navigation.accounts;
    }
  }

  String? get icon => null;
}

class SideBarItem {
  const SideBarItem({
    required this.type,
    this.icon,
    this.children = const [],
    this.level = 0,
  });

  final SideBarItemType type;
  final String? icon;
  final List<SideBarItem> children;
  final int level;

  String title(BuildContext context) => type.title(context);

  void Function() get onTap => children.isNotEmpty
      ? () => mainFlowBloc.toggleSideBarItem(type)
      : () => mainFlowBloc.selectSideBarItem(type);

  bool get isParent => children.isNotEmpty;
}

MainFlowSideBarController get mainFlowSideBarController =>
    Modular.get<MainFlowSideBarController>();

class MainFlowSideBarController {
  final List<SideBarItem> sideBarItems = [
    const SideBarItem(type: SideBarItemType.overview),
    const SideBarItem(
      type: SideBarItemType.financialMovement,
      children: [
        SideBarItem(type: SideBarItemType.releases, level: 1),
        SideBarItem(type: SideBarItemType.futureReleases, level: 1),
        SideBarItem(type: SideBarItemType.pastReleases, level: 1),
        SideBarItem(type: SideBarItemType.accountStatement, level: 1),
      ],
    ),
    const SideBarItem(
      type: SideBarItemType.registrations,
      children: [
        SideBarItem(type: SideBarItemType.categories, level: 1),
        SideBarItem(type: SideBarItemType.accounts, level: 1),
      ],
    ),
  ];

  List<SideBarItem> get flattenedItems {
    final flattened = <SideBarItem>[];

    for (final item in sideBarItems) {
      flattened.add(item);
      if (item.isParent && mainFlowBloc.isItemExpanded(item.type)) {
        flattened.addAll(item.children);
      }
    }

    return flattened;
  }
}
