import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/accounts_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/accounts/transaction_account_data.dart';

class CWAccountsList extends StatelessWidget {
  const CWAccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
        const CWDivider(width: double.infinity, height: 1),
        const Gap(7),
        Obx(() {
          final checkingAccounts = coreAccountsBloc.checkingAccounts;

          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: checkingAccounts.length,
                itemBuilder: (context, index) {
                  final account = checkingAccounts[index];
                  return _AccountItem(account: account);
                },
              ),
              const Gap(15),
              Padding(
                padding: const EdgeInsets.only(left: 85),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.t.common.labels.total,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Obx(
                      () => Row(
                        children: [
                          _ContainerItem(
                            child: CWAmoutValue(
                              value: coreAccountsBloc
                                  .totalAllAccountsBalance
                                  .value,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _ContainerItem(
                            child: CWAmoutValue(
                              value: coreAccountsBloc
                                  .totalAllAccountsProjectedBalance
                                  .value,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
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
        Image.asset(account.account.iconPath, width: 24, height: 24),
        const Gap(12),
        Text(account.account.name, style: const TextStyle(fontSize: 14)),
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
