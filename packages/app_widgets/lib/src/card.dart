import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

class CWCard extends StatelessWidget {
  const CWCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).customColors.third,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class CWSquareButton extends StatelessWidget {
  const CWSquareButton({required this.onTap, this.title, super.key});

  final String? title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CWAnimatedScaleButtonWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).customColors.button01,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          context.t.common.actions.save,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class CWAmoutValue extends StatelessWidget {
  const CWAmoutValue({
    required this.value,
    this.fontWeight,
    this.fontSize = 16,
    super.key,
  });

  final double value;
  final FontWeight? fontWeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.formatAmount(
        value,
        context,
      ),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: value < 0
            ? Theme.of(context).customColors.expense
            : Theme.of(context).customColors.income,
      ),
    );
  }
}
