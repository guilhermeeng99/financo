import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';
import 'package:financo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:financo/features/chat/presentation/widgets/chat_action_card.dart';
import 'package:financo/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:financo/features/chat/presentation/widgets/chat_day_divider.dart';
import 'package:financo/features/chat/presentation/widgets/chat_typing_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reverse-built list of bubbles, action cards, day dividers and the typing
/// indicator. Centralizes the per-message rendering decisions so the page
/// stays a thin shell.
class ChatTimeline extends StatelessWidget {
  const ChatTimeline({
    required this.messages,
    required this.isTyping,
    required this.handledActionIds,
    required this.onActionDismissed,
    required this.scrollController,
    super.key,
  });

  final List<ChatMessageEntity> messages;
  final bool isTyping;

  /// IDs of AI messages whose action card has been confirmed or cancelled.
  /// Tracked in the page (not the bloc) so phase 1 can land without bloc
  /// changes.
  final Set<String> handledActionIds;
  final ValueChanged<String> onActionDismissed;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries(context);

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: entries.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == 0) return const ChatTypingDots();
        final entryIndex = isTyping ? index - 1 : index;
        return entries[entryIndex];
      },
    );
  }

  /// Builds the entries top-down, then reverses — easier to reason about
  /// burst boundaries and day-divider insertion in chronological order.
  List<Widget> _buildEntries(BuildContext context) {
    final widgets = <Widget>[];
    DateTime? lastDay;
    ChatRole? lastRole;

    for (final m in messages) {
      final day = DateTime(
        m.createdAt.year,
        m.createdAt.month,
        m.createdAt.day,
      );

      if (lastDay == null || !_isSameDay(lastDay, day)) {
        widgets.add(ChatDayDivider(date: day));
        lastDay = day;
        // New day resets burst tracking so the first AI message of the day
        // gets its avatar.
        lastRole = null;
      }

      final isFirstOfBurst = lastRole != m.role;
      widgets.add(
        ChatBubble(
          message: m,
          showAvatar: m.role == ChatRole.assistant && isFirstOfBurst,
        ),
      );

      final hasAction = m.role == ChatRole.assistant &&
          m.metadata != null &&
          (m.metadata!['actionType'] as String?) != null &&
          !handledActionIds.contains(m.id);

      if (hasAction) {
        widgets.add(
          ChatActionCard(
            metadata: m.metadata!,
            onConfirm: () {
              context.read<ChatBloc>().add(
                ChatActionConfirmed(m.metadata!),
              );
              onActionDismissed(m.id);
            },
            onCancel: () => onActionDismissed(m.id),
          ),
        );
      }

      lastRole = m.role;
    }

    return widgets.reversed.toList();
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
