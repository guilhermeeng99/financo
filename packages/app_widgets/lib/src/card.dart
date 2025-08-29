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
