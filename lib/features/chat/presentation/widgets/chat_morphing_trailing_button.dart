import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/chat/presentation/widgets/chat_circle_button.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Trailing circular button of the composer that swaps icon based on
/// whether there's content to send (paper plane) or not (microphone).
/// Watches the [TextEditingController] so the swap is per-keystroke
/// without rebuilding the whole row.
class ChatMorphingTrailingButton extends StatelessWidget {
  const ChatMorphingTrailingButton({
    required this.controller,
    required this.hasImage,
    required this.isDisabled,
    required this.onSend,
    required this.onStartRecording,
    super.key,
  });

  final TextEditingController controller;
  final bool hasImage;

  /// True while the picked image is still being encoded — the send
  /// pathway isn't ready yet, so the button shows a spinner and ignores
  /// taps. Mic-mode taps are also blocked, since starting a recording
  /// while encoding would race the staged attachment.
  final bool isDisabled;
  final VoidCallback onSend;
  final VoidCallback onStartRecording;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (isDisabled) return _DisabledSpinner(color: colors.primary);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        final showSend = hasText || hasImage;
        return ChatCircleButton(
          icon: showSend
              ? FontAwesomeIcons.paperPlane
              : FontAwesomeIcons.microphone,
          // The mic uses the same primary fill as the send button — the
          // morph reads as "this is the action" rather than a state shift.
          color: colors.primary,
          onPressed: showSend ? onSend : onStartRecording,
          semanticLabel: showSend ? null : t.chat.audio.start,
        );
      },
    );
  }
}

/// Spinner placeholder shown while the staged attachment is encoding.
/// Matches [ChatCircleButton]'s footprint so the row doesn't shift.
class _DisabledSpinner extends StatelessWidget {
  const _DisabledSpinner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ChatCircleButton.size,
      height: ChatCircleButton.size,
      child: Material(
        color: color.withValues(alpha: 0.6),
        shape: const CircleBorder(),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
