import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt, this.metadata,
  });

  final String id;
  final String userId;
  final ChatRole role;
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, userId, role, content, metadata, createdAt];
}
