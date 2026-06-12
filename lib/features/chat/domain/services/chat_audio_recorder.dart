/// Captured voice note, already encoded for the transcription callable.
///
/// [base64Data] is the raw audio base64-encoded; [mimeType] matches the
/// container the platform recorder produced (`audio/webm` on web,
/// `audio/mp4` on mobile).
class ChatRecordedAudio {
  const ChatRecordedAudio({
    required this.base64Data,
    required this.mimeType,
  });

  final String base64Data;
  final String mimeType;
}

/// Microphone capture for the chat composer.
///
/// Project-owned contract that hides all platform IO (recorder plugin,
/// temp files, blob URLs, base64 encoding) so the input widget keeps only
/// UI state.
///
/// Usage:
/// ```dart
/// final recorder = GetIt.I<ChatAudioRecorder>();
/// if (await recorder.hasPermission()) {
///   await recorder.start();
///   final audio = await recorder.stop(); // or cancel() to discard
/// }
/// ```
abstract class ChatAudioRecorder {
  /// Whether the platform granted (or grants after prompting) mic access.
  Future<bool> hasPermission();

  /// Begins a new recording session.
  Future<void> start();

  /// Stops the session, cleans up the temporary capture, and returns the
  /// encoded audio — or `null` when nothing was captured (e.g. stop
  /// without a started session).
  Future<ChatRecordedAudio?> stop();

  /// Stops the session and discards whatever was captured.
  Future<void> cancel();

  /// Releases the underlying platform recorder. The instance must not be
  /// used afterwards.
  Future<void> dispose();
}
