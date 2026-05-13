import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.metadata,
    this.inlineImageBytes,
  });

  final String id;
  final String userId;
  final ChatRole role;
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  /// In-memory only. Set when the user attaches an image to a message so the
  /// bubble can render the thumbnail alongside the caption. Image bytes are
  /// intentionally NOT persisted to Firestore — reloading the chat history
  /// shows the caption text only. See chat spec §"Image input".
  final Uint8List? inlineImageBytes;

  @override
  List<Object?> get props => [
    id,
    userId,
    role,
    content,
    metadata,
    createdAt,
    inlineImageBytes,
  ];
}
