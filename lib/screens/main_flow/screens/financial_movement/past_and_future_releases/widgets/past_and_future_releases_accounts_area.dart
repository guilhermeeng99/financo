import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_bloc.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_service.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_types.dart';

class CWAPastAndFutureReleasesAccount extends StatelessWidget {
  const CWAPastAndFutureReleasesAccount({required this.type, super.key});

  final PastAndFutureReleasesType type;

  @override
  Widget build(BuildContext context) {
    return CWCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Obx(() {
          final accountCalculations = pastAndFutureReleasesBloc
              .getAccountCalculations(type);
          final totalBalance = pastAndFutureReleasesBloc
              .getTotalAllAccountsBalance(type);

          String title() {
            if (type == PastAndFutureReleasesType.past) {
              if (pastAndFutureReleasesBloc.selectedFinancialType ==
                  FinancialType.income) {
                return context.t.past_and_future_releases.total_received;
              } else {
                return context.t.past_and_future_releases.total_paid;
              }
            } else {
              if (pastAndFutureReleasesBloc.selectedFinancialType ==
                  FinancialType.income) {
                return context.t.past_and_future_releases.total_to_receive;
              } else {
                return context.t.past_and_future_releases.total_to_pay;
              }
            }
          }

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text(title(), style: const TextStyle(fontSize: 14))],
              ),
              const Gap(10),
              const CWDivider(width: double.infinity, height: 1),
              const Gap(7),
              Column(
                spacing: 15,
                children: [
                  _AccountsList(accountCalculations: accountCalculations),
                  _AccountsTotal(totalBalance: totalBalance),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _AccountsList extends StatelessWidget {
  const _AccountsList({required this.accountCalculations});

  final List<PastAndFutureReleasesAccountCalculationResult> accountCalculations;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: accountCalculations.length,
      itemBuilder: (context, index) {
        final calculationResult = accountCalculations[index];
        return _AccountItem(calculationResult: calculationResult);
      },
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({required this.calculationResult});

  final PastAndFutureReleasesAccountCalculationResult calculationResult;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: calculationResult.account.isEnabled.value,
            onChanged: (value) {
              calculationResult.account.isEnabled.value = value ?? true;
            },
          ),
        ),
        Image.asset(
          calculationResult.account.account.iconPath,
          width: 24,
          height: 24,
        ),
        const Gap(12),
        Text(
          calculationResult.account.account.name,
          style: const TextStyle(fontSize: 14),
        ),
        const Spacer(),
        CWContainerAmoutValue(
          child: CWAmoutValue(value: calculationResult.calculatedBalance),
        ),
      ],
    );
  }
}

class _AccountsTotal extends StatelessWidget {
  const _AccountsTotal({required this.totalBalance});

  final double totalBalance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 85),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.t.common.labels.total,
            style: const TextStyle(fontSize: 14),
          ),
          CWContainerAmoutValue(
            child: CWAmoutValue(
              value: totalBalance,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
