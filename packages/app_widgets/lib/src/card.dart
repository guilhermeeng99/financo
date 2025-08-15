import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

class CWCard extends StatelessWidget {
  const CWCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).customColors.third,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
