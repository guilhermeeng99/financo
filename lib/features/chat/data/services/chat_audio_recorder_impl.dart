import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:financo/features/chat/domain/services/chat_audio_recorder.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// [ChatAudioRecorder] backed by the `record` plugin.
///
/// Owns every platform-IO detail of voice capture: `record` for the mic,
/// `path_provider` + `dart:io` for the temp file on mobile, and `http` to
/// fetch the blob URL `record_web` hands back on web. Importing `dart:io`
/// is safe on web because every `File` touch sits behind a `kIsWeb` guard.
class ChatAudioRecorderImpl implements ChatAudioRecorder {
  final AudioRecorder _recorder = AudioRecorder();

  /// Fallback for [stop]/[cancel] — some platforms return `null` from the
  /// plugin's `stop()`, so we remember where we asked it to write.
  String? _currentRecordingPath;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    // On web, `path` is ignored by record_web (stop() returns a blob URL).
    // On mobile/desktop we write to a temp file.
    final path = kIsWeb ? '' : await _temporaryRecordingPath();
    await _recorder.start(
      const RecordConfig(bitRate: 96000, numChannels: 1),
      path: path,
    );
    _currentRecordingPath = path;
  }

  Future<String> _temporaryRecordingPath() async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/chat_audio_$timestamp.m4a';
  }

  @override
  Future<ChatRecordedAudio?> stop() async {
    final stoppedPath = await _recorder.stop() ?? _currentRecordingPath;
    if (stoppedPath == null || stoppedPath.isEmpty) return null;
    return ChatRecordedAudio(
      base64Data: base64Encode(await _readAndCleanUp(stoppedPath)),
      mimeType: kIsWeb ? 'audio/webm' : 'audio/mp4',
    );
  }

  /// Reads the captured bytes; on mobile also schedules the backing temp
  /// file's deletion (fire-and-forget — a leftover temp file is harmless).
  Future<List<int>> _readAndCleanUp(String path) async {
    if (kIsWeb) {
      final response = await http.get(Uri.parse(path));
      return response.bodyBytes;
    }
    final file = File(path);
    final bytes = await file.readAsBytes();
    unawaited(file.delete().catchError((_) => file));
    return bytes;
  }

  @override
  Future<void> cancel() async {
    final path = await _recorder.stop() ?? _currentRecordingPath;
    if (kIsWeb || path == null || path.isEmpty) return;
    final file = File(path);
    unawaited(file.delete().catchError((_) => file));
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}
