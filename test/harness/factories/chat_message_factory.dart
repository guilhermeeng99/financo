import 'package:financo/features/chat/data/models/chat_message_model.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageFactory {
  const ChatMessageFactory._();

  static ChatMessageEntity entity({
    String id = 'msg-1',
    String userId = 'user-1',
    String content = 'Hello',
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return ChatMessageEntity(
      id: id,
      userId: userId,
      role: ChatRole.user,
      content: content,
      metadata: metadata,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static ChatMessageEntity assistant({
    String id = 'msg-2',
    String userId = 'user-1',
    String content = 'Hi! How can I help you?',
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return ChatMessageEntity(
      id: id,
      userId: userId,
      role: ChatRole.assistant,
      content: content,
      metadata: metadata,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static ChatMessageEntity withMetadata({
    required Map<String, dynamic> metadata,
    String id = 'msg-action',
    String userId = 'user-1',
    String content = 'Transaction created!',
    DateTime? createdAt,
  }) {
    return ChatMessageEntity(
      id: id,
      userId: userId,
      role: ChatRole.assistant,
      content: content,
      metadata: metadata,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static ChatMessageModel model({
    String id = 'msg-1',
    String userId = 'user-1',
    ChatRole role = ChatRole.user,
    String content = 'Hello',
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id,
      userId: userId,
      role: role,
      content: content,
      metadata: metadata,
      createdAt: createdAt ?? DateTime(2024),
    );
  }

  static List<ChatMessageEntity> history() {
    return [
      entity(
        content: 'How much did I spend today?',
        createdAt: DateTime(2024, 1, 1, 10),
      ),
      assistant(
        content: 'Let me check your transactions.',
        createdAt: DateTime(2024, 1, 1, 10, 1),
      ),
      entity(
        id: 'msg-3',
        content: r'Add a new expense of R$ 50',
        createdAt: DateTime(2024, 1, 1, 10, 2),
      ),
    ];
  }
}
