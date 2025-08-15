import 'package:app_core/app_core.dart';

class CWAnimatedScaleButtonWidget extends StatelessWidget {
  const CWAnimatedScaleButtonWidget({
    required this.child,
    super.key,
    this.scale = 1.1,
    this.scaleY,
    this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.linear,
    this.onTapWithDetails,
    this.onDoubleTap,
    this.avoidMultipleClicks = true,
    this.alignment = Alignment.center,
  });
  final Widget child;

  final void Function()? onTap;
  final void Function()? onDoubleTap;
  final void Function(TapUpDetails details)? onTapWithDetails;
  final bool avoidMultipleClicks;

  final double? scale;
  final double? scaleY;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return CWAnimatedButtonWidget(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onTapWithDetails: onTapWithDetails,
      avoidMultipleClicks: avoidMultipleClicks,
      child: child,
      builder: (BuildContext context, double animation, Widget? child) {
        return Transform.scale(
          scale: scale != null
              ? CWAnimatedButtonWidget.valueFromAnimation(
                  onTap != null || onTapWithDetails != null ? scale! : 1,
                  animation,
                )
              : scale,
          scaleY: scaleY != null
              ? CWAnimatedButtonWidget.valueFromAnimation(
                  onTap != null || onTapWithDetails != null ? scaleY! : 1,
                  animation,
                )
              : null,
          alignment: alignment,
          child: child,
        );
      },
    );
  }
}

class CWAnimatedButtonWidget extends StatefulWidget {
  const CWAnimatedButtonWidget({
    required this.builder,
    this.onTap,
    this.onDoubleTap,
    this.onTapWithDetails,
    this.child,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.linear,
    super.key,
    this.avoidMultipleClicks = true,
  });

  final Widget? child;
  final Widget Function(BuildContext context, double animation, Widget? child)
      builder;
  final void Function()? onTap;
  final void Function()? onDoubleTap;
  final void Function(TapUpDetails details)? onTapWithDetails;
  final bool avoidMultipleClicks;

  final Duration duration;
  final Curve curve;

  static double valueFromAnimation(double target, double animation) {
    return (target - 1) * animation + 1;
  }

  @override
  State<CWAnimatedButtonWidget> createState() => _CWAnimatedButtonWidgetState();
}

class _CWAnimatedButtonWidgetState extends State<CWAnimatedButtonWidget> {
  DateTime? _lastClickTime;
  bool _isTapDown = false;

  void _setTapDown(bool value) {
    setState(() {
      _isTapDown = value;
    });
  }

  void _onClick(void Function() onTap) {
    if (!widget.avoidMultipleClicks) {
      onTap();
      return;
    }
    final currentTime = DateTime.now();
    if (_lastClickTime == null ||
        currentTime.difference(_lastClickTime!) >
            const Duration(milliseconds: 300)) {
      _lastClickTime = currentTime;
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null || widget.onTapWithDetails != null) {
          _setTapDown(true);
        }
      },
      onTapUp: (d) async {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!context.mounted) return;
        _setTapDown(false);
        _onClick(() {
          widget.onTap?.call();
          widget.onTapWithDetails?.call(d);
        });
      },
      onTapCancel: () {
        _setTapDown(false);
      },
      onDoubleTap: widget.onDoubleTap,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: _isTapDown ? 1 : 0),
        duration: widget.duration,
        curve: widget.curve,
        builder: widget.builder,
        child: widget.child,
      ),
    );
  }
}
