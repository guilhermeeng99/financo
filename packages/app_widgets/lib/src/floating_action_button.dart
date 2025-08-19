import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/app_theme.dart';

class CWFloatingActionButton extends StatelessWidget {
  const CWFloatingActionButton({
    required this.onTap,
    required this.tooltipMessage,
     this.onHover,
    super.key,
  });

  final void Function() onTap;
  final String tooltipMessage;
  final void Function(bool isHovering)? onHover;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: Tooltip(
        message: context.t.new_account,
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: onTap,
            backgroundColor: Theme.of(context).customColors.button02,
            elevation: 0,
            hoverElevation: 0,
            shape: const CircleBorder(),
            child: Transform.rotate(
              angle: 45.toRadians(),
              child: SvgPicture.asset(svgs.x, width: 14, height: 14),
            ),
          ),
        ),
      ),
    );
  }
}
