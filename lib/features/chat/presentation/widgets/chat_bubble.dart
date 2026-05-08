import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:financo/features/chat/presentation/widgets/chat_channel_badge.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  // Cap the bubble width at ~360 logical px on wide layouts (web/desktop)
  // so portrait screenshots don't blow up to half the viewport. On phones
  // 72 % of width is already tighter than the cap, so the cap is a no-op.
  static const _kMaxBubbleWidth = 360.0;
  // Tall portrait images get reined in to a comfortable WhatsApp-ish
  // thumbnail size — wide images stay constrained by the bubble width.
  static const _kMaxImageHeight = 320.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageBytes = message.inlineImageBytes;
    // After a chat reload the original bytes are gone (per spec: image
    // bytes are not persisted) but `metadata.hadImage` survives, so the
    // bubble can render a small placeholder tile instead of an empty
    // bubble. Honest signal: "you sent an image here" without trying to
    // fake the original content.
    final hadImageInHistory = message.metadata?['hadImage'] == true;
    final hasImage = imageBytes != null || hadImageInHistory;
    final hasText = message.content.trim().isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = screenWidth * 0.72 < _kMaxBubbleWidth
        ? screenWidth * 0.72
        : _kMaxBubbleWidth;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
              // antiAlias so the image inside is clipped by the bubble's own
              // rounded corners — no inner ClipRRect needed. WhatsApp-style:
              // the thumbnail is flush to the bubble edges; only the
              // bottom-right "tail" radius (4px) differs.
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasImage)
                    // Subtle 3 px frame of bubble color around the image
                    // (WhatsApp style). The inner radius (15) is concentric
                    // with the bubble's 18 → 3 = 15 corner. When a caption
                    // follows we drop the bottom inset so the image meets
                    // the caption padding flush.
                    Padding(
                      padding: hasText
                          ? const EdgeInsets.fromLTRB(3, 3, 3, 0)
                          : const EdgeInsets.all(3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: _kMaxImageHeight,
                          ),
                          child: imageBytes != null
                              ? Image.memory(imageBytes, fit: BoxFit.cover)
                              : const _MissingImagePlaceholder(),
                        ),
                      ),
                    ),
                  if (hasText)
                    Padding(
                      // When a caption follows an image, give it the same
                      // horizontal padding as a text-only bubble so the line
                      // measure stays comfortable, with a slightly tighter
                      // top inset so the caption hugs the image.
                      padding: hasImage
                          ? const EdgeInsets.fromLTRB(14, 8, 14, 10)
                          : const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                      child: Text(
                        message.content,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (message.channel == ChatChannel.whatsapp) const ChatChannelBadge(),
        ],
      ),
    );
  }
}

/// Tile shown in place of the image after a chat reload — original bytes
/// were never persisted (per chat spec), but `metadata.hadImage` flagged
/// that there was one. Honest signal: photo icon + "Image not available"
/// so the user understands the gap rather than seeing an empty bubble.
class _MissingImagePlaceholder extends StatelessWidget {
  const _MissingImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    // The bubble's Column stretches the placeholder to bubble width — pin a
    // landscape aspect so a missing thumbnail still reads as "this was an
    // image" without dominating the bubble vertically.
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        color: Colors.white.withValues(alpha: 0.12),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.image,
              size: 28,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 8),
            Text(
              t.chat.image.missing,
              style: context.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
