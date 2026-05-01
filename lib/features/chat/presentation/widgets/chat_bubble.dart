import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:financo/features/chat/presentation/widgets/chat_channel_badge.dart';
import 'package:flutter/material.dart';

/// Single conversation turn — speech-bubble layout with a tail on the side
/// nearest the speaker. AI bubbles get an avatar (only on the first message
/// of a same-speaker burst, to declutter back-and-forth turns).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    this.showAvatar = true,
    super.key,
  });

  final ChatMessageEntity message;

  /// When several AI messages arrive consecutively, only the first shows the
  /// avatar; the rest keep an empty slot so bubbles stay aligned.
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    if (isUser) return _UserBubble(message: message);
    return _AiBubble(message: message, showAvatar: showAvatar);
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.message, required this.showAvatar});

  final ChatMessageEntity message;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 32,
            child: showAvatar ? const ChatAvatar() : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground,
                      height: 1.4,
                    ),
                  ),
                ),
                if (message.channel == ChatChannel.whatsapp)
                  const ChatChannelBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.content,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.channel == ChatChannel.whatsapp) const ChatChannelBadge(),
        ],
      ),
    );
  }
}
