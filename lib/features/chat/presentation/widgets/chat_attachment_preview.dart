import 'package:financo/core/extensions/context_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Thumbnail of the image staged in the chat composer, with a remove
/// badge on the corner. Shown above the text field until the message is
/// sent or the attachment dismissed.
class ChatAttachmentPreview extends StatelessWidget {
  const ChatAttachmentPreview({
    required this.bytes,
    required this.isEncoding,
    required this.onRemove,
    super.key,
  });

  /// Raw picker bytes — already available before base64 encoding ends,
  /// so the thumbnail paints immediately.
  final Uint8List bytes;

  /// Dim the thumbnail and show a centered spinner while base64 + BlurHash
  /// are still being computed. The thumbnail itself is already painted
  /// (bytes are available) — this just signals "wait, almost ready".
  final bool isEncoding;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.memory(
                    bytes,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                  if (isEncoding) const _EncodingOverlay(),
                ],
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: colors.surface,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.surfaceVariant,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.xmark,
                        size: 10,
                        color: colors.onBackground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncodingOverlay extends StatelessWidget {
  const _EncodingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
