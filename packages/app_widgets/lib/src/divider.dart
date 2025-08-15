import 'package:app_widgets/app_widgets.dart';

class CWDivider extends StatelessWidget {
  const CWDivider({
    super.key,
    this.height = 1,
    this.width = double.infinity,
    this.color,
  });

  final double height;
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CWCard(
      height: height,
      width: width,
      strokeWidth: 0,
      backgroundColor: color ?? Theme.of(context).dividerColor,
    );
  }
}

class CWDividerV extends StatelessWidget {
  const CWDividerV({
    super.key,
    this.height = double.infinity,
    this.width = 1,
    this.color,
    this.borderRadius,
  });

  final double? height;
  final double width;
  final Color? color;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return CWCard(
      height: height,
      width: width,
      strokeWidth: 0,
      backgroundColor: color ?? Theme.of(context).dividerColor,
      borderRadius: borderRadius,
    );
  }
}
