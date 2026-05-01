import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The "face" of the AI assistant. A rounded-square tile (12 radius) tinted
/// with the primary color — used as the avatar in chat bubbles and as the
/// hero element in the empty state. Centralizing it keeps the brand
/// consistent everywhere it shows up.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({this.size = 32, this.iconSize, super.key});

  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.wandMagicSparkles,
          size: iconSize ?? size * 0.45,
          color: colors.primary,
        ),
      ),
    );
  }
}
