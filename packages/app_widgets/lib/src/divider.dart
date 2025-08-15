import 'package:app_widgets/app_widgets.dart';

class CWDivider extends StatelessWidget {
  const CWDivider({
    this.height,
    this.width,
    super.key,
  });

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 1,
      height: height ?? 27,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
