import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.userId,
    required super.role,
    required super.content,
    required super.createdAt, super.metadata,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      userId: data['userId'] as String,
      role: ChatRole.values.byName(data['role'] as String),
      content: data['content'] as String,
      metadata: data['metadata'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      userId: entity.userId,
      role: entity.role,
      content: entity.content,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role.name,
      'content': content,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
