import 'package:app_core/app_core.dart';

enum StrokeType {
  inside(BorderSide.strokeAlignInside),
  outside(BorderSide.strokeAlignOutside),
  center(BorderSide.strokeAlignCenter);

  const StrokeType(this._value);

  final double _value;
}

class CWCard extends HookWidget {
  const CWCard({
    this.width,
    this.height,
    this.child,
    this.strokeWidth = 2,
    this.elevation = 0,
    this.shadowColor,
    this.strokeColor,
    this.backgroundColor,
    this.borderRadius,
    this.gradient,
    this.customBorderRadius,
    this.shape = BoxShape.rectangle,
    this.onTap,
    this.alignment,
    this.padding,
    this.constraints,
    this.strokeType = StrokeType.outside,
    this.duration,
    this.curve = Curves.linear,
    super.key,
  });

  final double? width;
  final double? height;
  final double elevation;
  final double strokeWidth;

  final StrokeType strokeType;

  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final BorderRadius? customBorderRadius;
  final Color? shadowColor;
  final Color? strokeColor;
  final Color? backgroundColor;

  final Duration? duration;
  final Curve curve;

  final Gradient? gradient;

  final BoxShape shape;

  final Widget? child;
  final AlignmentGeometry? alignment;
  final void Function()? onTap;
  final BoxConstraints? constraints;

  double get _elevation {
    if (elevation == 0) return 0;
    switch (strokeType) {
      case StrokeType.inside:
        return elevation;
      case StrokeType.outside:
        return elevation + strokeWidth;
      case StrokeType.center:
        return elevation + strokeWidth / 2;
    }
  }

  Widget _buildContainer(BuildContext context, double animatedElevation) {
    if (duration != null) {
      return AnimatedContainer(
        width: width,
        height: height,
        constraints: constraints,
        duration: duration!,
        curve: curve,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardColor,
          gradient: gradient,
          borderRadius: borderRadiusRadius,
          shape: shape,
          boxShadow: boxShadow(context, animatedElevation),
          border: border(context),
        ),
        padding: padding,
        alignment: alignment,
        child: child,
      );
    }
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        gradient: gradient,
        borderRadius: borderRadiusRadius,
        shape: shape,
        boxShadow: boxShadow(context, animatedElevation),
        border: border(context),
      ),
      padding: padding,
      alignment: alignment,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildedChild(double tappedAnimValue) {
      final animatedElevation = tappedAnimValue * _elevation;
      return Transform.translate(
        offset: Offset(0, animatedElevation),
        child: _buildContainer(context, animatedElevation),
      );
    }

    if (onTap == null) return buildedChild(0);

    final isTapped = useState(false);
    Future<void> setTappedFalse() async {
      await Future.delayed(const Duration(milliseconds: 20));
      if (!context.mounted) return;
      isTapped.value = false;
    }

    return InkWell(
      onTapDown: (_) => isTapped.value = true,
      onTapUp: (_) => setTappedFalse(),
      onTapCancel: setTappedFalse,
      onTap: onTap,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: isTapped.value ? 1 : 0),
        duration: const Duration(milliseconds: 100),
        builder: (_, value, __) => buildedChild(value),
      ),
    );
  }

  List<BoxShadow>? boxShadow(BuildContext context, double animatedElevation) {
    if (_elevation == 0) return null;
    return [
      BoxShadow(
        color: shadowColor ?? Theme.of(context).shadowColor,
        offset: Offset(0, _elevation - animatedElevation),
      ),
    ];
  }

  BorderRadius? get borderRadiusRadius {
    if (customBorderRadius != null) return customBorderRadius;
    if (shape == BoxShape.rectangle) {
      if (borderRadius == null) return null;
      return BorderRadius.circular(borderRadius!);
    } else {
      return null;
    }
  }

  BoxBorder? border(BuildContext context) {
    if (strokeWidth == 0) return null;
    return Border.all(
      color: strokeColor ?? Theme.of(context).dividerColor,
      width: strokeWidth,
      strokeAlign: strokeType._value,
    );
  }
}

class CWCardCircular extends CWCard {
  const CWCardCircular({
    required double size,
    super.child,
    super.strokeWidth = 2,
    super.elevation = 0,
    super.shadowColor,
    super.strokeColor,
    super.alignment,
    super.padding,
    super.backgroundColor,
    super.onTap,
    super.key,
    super.strokeType = StrokeType.outside,
    super.duration,
    super.curve,
  }) : super(
          width: size,
          height: size,
          shape: BoxShape.circle,
        );
}
