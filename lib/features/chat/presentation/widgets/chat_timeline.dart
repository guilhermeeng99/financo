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
    required this.cancelledActionIds,
    required this.onActionCancelled,
    required this.scrollController,
    super.key,
  });

  final List<ChatMessageEntity> messages;
  final bool isTyping;

  /// IDs of AI messages whose action card the user dismissed via Cancel.
  /// Confirmed actions are derived from the messages list itself (via
  /// `metadata.originActionId` on the result message), so they survive a
  /// chat reload. Cancellation never touches Firestore — losing the
  /// cancelled state on reload is benign (the action wasn't executed).
  final Set<String> cancelledActionIds;
  final ValueChanged<String> onActionCancelled;
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
    final confirmedActionIds = _deriveActionIdsByKind(
      messages,
      'actionResult',
    );
    // Proposals that failed preflight: the card is suppressed entirely —
    // the rejection bubble (already in `messages`) carries the explanation.
    // Confirming a card the bloc would have rejected is the exact UX bug
    // this set prevents.
    final rejectedActionIds = _deriveActionIdsByKind(
      messages,
      'actionRejected',
    );
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

      final isProposal = m.role == ChatRole.assistant &&
          m.metadata != null &&
          (m.metadata!['actionType'] as String?) != null;

      if (isProposal && !rejectedActionIds.contains(m.id)) {
        final ChatActionStatus? status;
        if (confirmedActionIds.contains(m.id)) {
          status = ChatActionStatus.confirmed;
        } else if (cancelledActionIds.contains(m.id)) {
          status = ChatActionStatus.cancelled;
        } else {
          status = null;
        }

        widgets.add(
          ChatActionCard(
            metadata: m.metadata!,
            status: status,
            onConfirm: status == null
                ? () => context.read<ChatBloc>().add(
                      ChatActionConfirmed(
                        actionMessageId: m.id,
                        metadata: m.metadata!,
                      ),
                    )
                : null,
            onCancel: status == null ? () => onActionCancelled(m.id) : null,
          ),
        );
      }

      lastRole = m.role;
    }

    return widgets.reversed.toList();
  }

  static Set<String> _deriveActionIdsByKind(
    List<ChatMessageEntity> messages,
    String kind,
  ) {
    final ids = <String>{};
    for (final m in messages) {
      if (m.metadata?['kind'] != kind) continue;
      final originId = m.metadata?['originActionId'] as String?;
      if (originId != null) ids.add(originId);
    }
    return ids;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
