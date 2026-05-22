import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Circular, tinted icon button used in app-bar action rows across the app
/// (delete, import, add…). Renders a 36×36 [Material] circle filled with the
/// accent at 12% opacity and a centred FontAwesome glyph, wrapped in a
/// [Tooltip].
///
/// Example:
/// ```dart
/// FinancoAppBarIconButton(
///   icon: FontAwesomeIcons.trashCan,
///   color: context.appColors.error,
///   tooltip: t.general.delete,
///   onPressed: _confirmDelete,
/// )
/// ```
class FinancoAppBarIconButton extends StatelessWidget {
  const FinancoAppBarIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final FaIconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(child: FaIcon(icon, size: 14, color: color)),
          ),
        ),
      ),
    );
  }
}
