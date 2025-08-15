import 'package:app_core/app_core.dart';

class AppVisible extends StatelessWidget {
  const AppVisible({
    required this.child,
    this.visible = false,
    super.key,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      maintainSemantics: true,
      child: child,
    );
  }
}
