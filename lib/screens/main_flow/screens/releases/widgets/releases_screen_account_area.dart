import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/releases/releases_bloc.dart';

class CWAReleasesScreenAccount extends StatelessWidget {
  const CWAReleasesScreenAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return const CWCard(
      child: Column(spacing: 15, children: [_Accounts(), _Results()]),
    );
  }
}

class _Accounts extends StatelessWidget {
  const _Accounts();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final checkingAccounts = accountsBloc.checkingAccounts;

      return Column(
        children: [
          const Gap(15),
          ListView.builder(
            shrinkWrap: true,
            itemCount: checkingAccounts.length,
            itemBuilder: (context, index) {
              final account = checkingAccounts[index];
              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 15),
                child: Row(
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
                    Text(account.a.name, style: const TextStyle(fontSize: 14)),
                    const Spacer(),
                    CWAmoutValue(value: account.finalBalance),
                  ],
                ),
              );
            },
          ),
          const Gap(15),
          Padding(
            padding: const EdgeInsets.only(left: 85, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.t.common.labels.total,
                  style: const TextStyle(fontSize: 14),
                ),
                Obx(
                  () => CWAmoutValue(
                    value: accountsBloc.totalEnabledAccountsBalance,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
        ],
      );
    });
  }
}

class _Results extends StatelessWidget {
  const _Results();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
