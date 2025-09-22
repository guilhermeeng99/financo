import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/transaction_account_data.dart';
import 'package:financo/screens/main_flow/screens/home/home_bloc.dart';
import 'package:financo/screens/main_flow/screens/home/home_model.dart';
import 'package:financo/screens/main_flow/screens/home/widgets/home_screen_container.dart';

class CWHomeScreenAccountsList extends StatelessWidget {
  const CWHomeScreenAccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeScreenContainer(
      title: context.t.overview.cash_balance,
      bottomChild: const _Total(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(
                () => Checkbox(
                  value: homeBloc.areAllAccountsEnabled,
                  tristate: true,
                  onChanged: (value) => homeBloc.toggleAllAccounts(),
                ),
              ),
              const Spacer(),
              _ContainerItem(
                child: Text(
                  context.t.common.labels.confirmed(n: 1),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              _ContainerItem(
                child: Text(
                  context.t.common.labels.projected(n: 1),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const Gap(10),
          Obx(() {
            final checkingAccounts = homeBloc.checkingAccounts;

            return Column(
              children: checkingAccounts
                  .map((account) => _AccountItem(account: account))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 55, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.t.common.labels.total,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Obx(
            () => Row(
              children: [
                _ContainerItem(
                  child: CWAmoutValue(
                    value: homeBloc.totalAllAccountsBalance.value,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _ContainerItem(
                  child: CWAmoutValue(
                    value: homeBloc.totalAllAccountsProjectedBalance.value,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({required this.account});

  final TransactionsAccount account;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: account.isEnabled.value,
            onChanged: (value) {
              account.isEnabled.value = value ?? true;
            },
          ),
        ),
        InkWell(
          onTap: () => homeModel.onTapGoToAccountStatement(account.account.id),
          child: Row(
            children: [
              Image.asset(account.account.iconPath, width: 24, height: 24),
              const Gap(12),
              Text(account.account.name, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        const Spacer(),
        Obx(
          () => Row(
            children: [
              _ContainerItem(
                child: CWAmoutValue(value: account.filteredBalance.value),
              ),
              _ContainerItem(
                child: CWAmoutValue(
                  value: account.filteredProjectedBalance.value,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContainerItem extends StatelessWidget {
  const _ContainerItem({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      width: 100,
      child: child,
    );
  }
}
