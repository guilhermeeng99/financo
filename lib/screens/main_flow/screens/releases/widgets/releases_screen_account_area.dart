import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/bloc/account_bloc.dart';

class CWAReleasesScreenAccount extends StatelessWidget {
  const CWAReleasesScreenAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return const CWCard(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(spacing: 25, children: [_Accounts(), _Results()]),
      ),
    );
  }
}

class _Accounts extends StatelessWidget {
  const _Accounts();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ContainerItem(
              child: Text(
                context.t.common.labels.confirmed,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            _ContainerItem(
              child: Text(
                context.t.common.labels.projected,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const Gap(10),
        const CWDivider(width: double.infinity, height: 1),
        const Gap(7),
        Obx(() {
          final checkingAccounts = transactionsAccountsBloc.checkingAccounts;

          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: checkingAccounts.length,
                itemBuilder: (context, index) {
                  final account = checkingAccounts[index];
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
                      Image.asset(account.a.iconPath, width: 24, height: 24),
                      const Gap(12),
                      Text(
                        account.a.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      Obx(
                        () => Row(
                          children: [
                            _ContainerItem(
                              child: CWAmoutValue(
                                value: account.filteredBalance.value,
                              ),
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
                              value: transactionsAccountsBloc
                                  .totalFilteredBalance
                                  .value,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _ContainerItem(
                            child: CWAmoutValue(
                              value: transactionsAccountsBloc
                                  .totalFilteredProjectedBalance
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

class _Results extends StatelessWidget {
  const _Results();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: CWDivider(height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                context.t.common.labels.result(n: 2),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Expanded(child: CWDivider(height: 1)),
          ],
        ),
        Container(),
      ],
    );
  }
}
