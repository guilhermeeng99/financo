import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Circular filled action button shared by the chat composer rows
/// (send / mic / record-cancel / record-stop). Swapping [icon] runs a
/// scale+fade morph so mode changes read as one button changing action.
class ChatCircleButton extends StatelessWidget {
  const ChatCircleButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.iconSize = 16,
    this.semanticLabel,
    super.key,
  });

  /// Diameter of the button. Exposed so siblings (e.g. the disabled
  /// spinner placeholder in the composer) can match its footprint.
  static const double size = 44;

  final FaIconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double iconSize;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: FaIcon(
                  icon,
                  key: ValueKey(icon),
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
