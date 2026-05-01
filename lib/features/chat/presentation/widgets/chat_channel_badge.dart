import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Tiny "via WhatsApp" tag rendered under bubbles whose source channel is
/// WhatsApp. The spec interleaves both channels in the same timeline — this
/// gives the user a quiet hint about where a message originated without
/// turning it into a separate visual lane.
class ChatChannelBadge extends StatelessWidget {
  const ChatChannelBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.whatsapp,
            size: 10,
            color: colors.onBackgroundLight,
          ),
          const SizedBox(width: 4),
          Text(
            t.chat.viaWhatsapp,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onBackgroundLight,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
