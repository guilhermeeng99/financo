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
  financialMovement,
  pastReleases,
  creditCard,
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
      case SideBarItemType.financialMovement:
        return null;
      case SideBarItemType.futureReleases:
        return '${ro.mainFlow.financialMovement.pastAndFutureReleases.route}?type=future';
      case SideBarItemType.pastReleases:
        return '${ro.mainFlow.financialMovement.pastAndFutureReleases.route}?type=past';
      case SideBarItemType.releases:
        return ro.mainFlow.financialMovement.releases.route;
      case SideBarItemType.accountStatement:
        return ro.mainFlow.accountStatement.route;
      case SideBarItemType.creditCard:
        return ro.mainFlow.creditCard.route;
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
      case SideBarItemType.financialMovement:
        return context.t.navigation.financial_movement;
      case SideBarItemType.futureReleases:
        return context.t.navigation.to_pay_and_to_receive;
      case SideBarItemType.pastReleases:
        return context.t.navigation.paid_and_received;
      case SideBarItemType.accountStatement:
        return context.t.navigation.account_statement;
      case SideBarItemType.creditCard:
        return context.t.navigation.credit_card;
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
  final IconData? icon;
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
    const SideBarItem(
      type: SideBarItemType.financialMovement,
      icon: Icons.paid,
      children: [
        SideBarItem(
          type: SideBarItemType.releases,
          icon: Icons.timeline,
          level: 1,
        ),
        SideBarItem(
          type: SideBarItemType.pastReleases,
          icon: Icons.graphic_eq,
          level: 1,
        ),
        SideBarItem(
          type: SideBarItemType.futureReleases,
          icon: Icons.scatter_plot,
          level: 1,
        ),
      ],
    ),
    const SideBarItem(
      type: SideBarItemType.accountStatement,
      icon: Icons.account_balance,
    ),
    const SideBarItem(
      type: SideBarItemType.creditCard,
      icon: Icons.credit_card,
    ),
    const SideBarItem(
      type: SideBarItemType.registrations,
      icon: Icons.label,
      children: [
        SideBarItem(
          type: SideBarItemType.categories,
          icon: Icons.sell,
          level: 1,
        ),
        SideBarItem(
          type: SideBarItemType.accounts,
          icon: Icons.wallet,
          level: 1,
        ),
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
