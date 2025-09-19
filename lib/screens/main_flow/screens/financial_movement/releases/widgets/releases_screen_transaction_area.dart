import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_bloc.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_filter.dart';
import 'package:financo/screens/main_flow/screens/core/transactions/transactions_widget.dart';

class CWAReleasesScreenTransactions extends StatelessWidget {
  const CWAReleasesScreenTransactions({required this.transactions, super.key});

  final List<TransactionI> transactions;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CWTransactionsTable(transactions: transactions),
          const _TransactionBottomFilter(),
        ],
      ),
    );
  }
}

class _TransactionBottomFilter extends StatelessWidget {
  const _TransactionBottomFilter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: TransactionFilterType.values
          .map(_TransactionBottomFilterItem.new)
          .toList(),
    );
  }
}

class _TransactionBottomFilterItem extends StatelessWidget {
  const _TransactionBottomFilterItem(this.filterType);

  final TransactionFilterType filterType;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = coreTransactionsBloc.isFilterActive(filterType);

      return InkWell(
        onTap: () {
          coreTransactionsBloc.toggleFilter(filterType);
        },
        onHover: (isHovering) {},
        hoverColor: Theme.of(context).customColors.secondary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Opacity(
            opacity: isSelected ? 1.0 : 0.5,
            child: Row(
              spacing: 10,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: filterType.getColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(filterType.title(context)),
              ],
            ),
          ),
        ),
      );
    });
  }
}
