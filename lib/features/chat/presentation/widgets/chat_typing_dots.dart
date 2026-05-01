import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:flutter/material.dart';

/// Three softly-bouncing dots inside an AI bubble. Replaces the static
/// FontAwesome circles that read as a frozen UI to first-time users.
class ChatTypingDots extends StatefulWidget {
  const ChatTypingDots({super.key});

  @override
  State<ChatTypingDots> createState() => _ChatTypingDotsState();
}

class _ChatTypingDotsState extends State<ChatTypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ChatAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Dot(progress: _controller.value, delay: 0),
                  const SizedBox(width: 4),
                  _Dot(progress: _controller.value, delay: 0.2),
                  const SizedBox(width: 4),
                  _Dot(progress: _controller.value, delay: 0.4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.progress, required this.delay});

  final double progress;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final shifted = (progress - delay) % 1.0;
    // 0..0.5 fades up, 0.5..1.0 fades back down — simple ping-pong opacity.
    final t = shifted < 0.5 ? shifted * 2 : (1 - shifted) * 2;
    final opacity = 0.3 + 0.7 * t.clamp(0, 1);
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: colors.onBackgroundLight.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
