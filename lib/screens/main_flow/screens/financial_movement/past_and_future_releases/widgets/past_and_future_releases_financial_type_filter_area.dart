import 'package:app_database/app_database.dart';
import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';
import 'package:financo/screens/main_flow/screens/financial_movement/past_and_future_releases/past_and_future_releases_bloc.dart';

class CWAPastAndFutureReleasesFinancialTypeFilter extends StatelessWidget {
  const CWAPastAndFutureReleasesFinancialTypeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedType = pastAndFutureReleasesBloc.selectedFinancialType;

      return ColoredBox(
        color: Theme.of(context).customColors.secondary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 40,
          children: [
            _TabButton(
              label: context.t.transactions.types.expense,
              financialType: FinancialType.expense,
              isSelected: selectedType == FinancialType.expense,
            ),
            _TabButton(
              label: context.t.transactions.types.income,
              financialType: FinancialType.income,
              isSelected: selectedType == FinancialType.income,
            ),
          ],
        ),
      );
    });
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.financialType,
    required this.isSelected,
  });

  final String label;
  final FinancialType financialType;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pastAndFutureReleasesBloc.setFinancialTypeFilter(financialType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? Theme.of(context).dividerColor
                        : Theme.of(context).customColors.secondary,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
