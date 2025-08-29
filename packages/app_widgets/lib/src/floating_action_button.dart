import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

class CWFloatingActionButton extends StatelessWidget {
  const CWFloatingActionButton({
    required this.onTap,
    required this.tooltipMessage,
    this.icon,
    super.key,
    this.size,
  });

  final void Function() onTap;
  final String tooltipMessage;
  final IconData? icon;
  final double? size;
  @override
  Widget build(BuildContext context) {
    final auxSize = size ?? 60;

    return Tooltip(
      message: tooltipMessage,
      child: SizedBox(
        width: auxSize,
        height: auxSize,
        child: FloatingActionButton(
          onPressed: onTap,
          backgroundColor: Theme.of(context).customColors.button02,
          elevation: 0,
          hoverElevation: 0,
          shape: const CircleBorder(),
          child: Icon(
            icon ?? Icons.add,
            size: auxSize / 2,
          ),
        ),
      ),
    );
  }
}
