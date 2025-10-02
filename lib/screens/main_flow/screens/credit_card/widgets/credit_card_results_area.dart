import 'package:app_widgets/app_widgets.dart';
import 'package:financo/screens/main_flow/screens/credit_card/credit_card_bloc.dart';

class CWACreditCardResults extends StatelessWidget {
  const CWACreditCardResults({super.key});

  @override
  Widget build(BuildContext context) {
    return const CWCard(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          spacing: 40,
          children: [_CurrentBill(), _CurrentLimit()],
        ),
      ),
    );
  }
}

class _CurrentBill extends StatelessWidget {
  const _CurrentBill();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!creditCardBloc.hasValidSelection) {
        return const SizedBox.shrink();
      }

      final billDates = creditCardBloc.currentBillDates;
      final billResults = creditCardBloc.currentBillResults;

      if (billDates == null || billResults == null) {
        return const SizedBox.shrink();
      }

      return Column(
        spacing: 10,
        children: [
          Row(
            children: [
              const Expanded(child: CWDivider(height: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  context.t.credit_card.current_bill,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Expanded(child: CWDivider(height: 1)),
            ],
          ),
          const Gap(10),
          _ResultsItemDate(
            title: context.t.credit_card.closing,
            date: billDates.closingDate,
          ),
          _ResultsItemDate(
            title: context.t.credit_card.due,
            date: billDates.dueDate,
          ),
          _ResultsItemValue(
            title: context.t.credit_card.previous_balance,
            value: billResults.previousBalance,
          ),
          _ResultsItemValue(
            title: context.t.credit_card.total_paid,
            value: billResults.totalPaid,
            isBold: true,
          ),
          _ResultsItemValue(
            title: context.t.common.labels.total,
            value: billResults.totalAmount,
            isBold: true,
          ),
          _ResultsItemValue(
            title: context.t.credit_card.amount_due,
            value: billResults.amountToPay,
            isBold: true,
          ),
        ],
      );
    });
  }
}

class _CurrentLimit extends StatelessWidget {
  const _CurrentLimit();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!creditCardBloc.hasValidSelection) {
        return const SizedBox.shrink();
      }

      final billResults = creditCardBloc.currentBillResults;

      if (billResults == null) {
        return const SizedBox.shrink();
      }

      return Column(
        spacing: 10,
        children: [
          Row(
            children: [
              const Expanded(child: CWDivider(height: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  context.t.credit_card.limit,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Expanded(child: CWDivider(height: 1)),
            ],
          ),
          const Gap(10),
          _ResultsItemValue(
            title: context.t.credit_card.account_limit,
            value: billResults.creditLimit,
          ),
          _ResultsItemValue(
            title: context.t.common.labels.used,
            value: billResults.usedLimit,
          ),
          _ResultsItemValue(
            title: context.t.common.labels.available,
            value: billResults.availableLimit,
          ),
        ],
      );
    });
  }
}

class _ResultsItemValue extends StatelessWidget {
  const _ResultsItemValue({
    required this.title,
    required this.value,
    this.isBold = false,
  });

  final String title;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
        CWContainerAmoutValue(
          child: CWAmoutValue(
            value: value,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}

class _ResultsItemDate extends StatelessWidget {
  const _ResultsItemDate({
    required this.title,
    required this.date,
  });

  final String title;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          date.formattedDateddMMyy(context: context),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
