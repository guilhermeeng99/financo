import 'package:equatable/equatable.dart';

/// In-memory representation of an image the user attached to a single chat
/// turn. Not persisted — discarded as soon as the Cloud Function returns.
class ChatImageAttachment extends Equatable {
  const ChatImageAttachment({
    required this.base64Data,
    required this.mimeType,
  });

  final String base64Data;
  final String mimeType;

  @override
  List<Object?> get props => [base64Data, mimeType];
}
