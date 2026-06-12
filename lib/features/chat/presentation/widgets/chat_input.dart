import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/domain/services/chat_audio_recorder.dart';
import 'package:financo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:financo/features/chat/presentation/widgets/chat_attachment_preview.dart';
import 'package:financo/features/chat/presentation/widgets/chat_input_audio_rows.dart';
import 'package:financo/features/chat/presentation/widgets/chat_morphing_trailing_button.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

/// Composer at the bottom of the chat. Messaging-app layout:
///
/// • Default: pill-shaped text field with paperclip inside (left) and a
///   single circular trailing button. Empty text → microphone (records);
///   typed text → paper plane (sends). The trailing button morphs between
///   the two icons with a small scale/fade swap.
/// • Recording: cancel button on the left, animated waveform + timer in
///   the middle, stop-and-send button on the right.
/// • Transcribing: spinner + label. Stops once the transcript is sent
///   automatically as a regular user message — no review step.
class ChatInput extends StatefulWidget {
  const ChatInput({
    required this.controller,
    required this.onAfterSend,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onAfterSend;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with TickerProviderStateMixin {
  // Factory-registered: each composer gets its own recorder instance and
  // owns its lifecycle (disposed below), mirroring a per-widget plugin.
  final ChatAudioRecorder _audioRecorder = GetIt.I<ChatAudioRecorder>();
  final _imagePicker = ImagePicker();
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _tickTimer;
  _PickedImage? _pickedImage;
  // True from picker-returned to encoding-finished. Drives the loading
  // overlay on the thumbnail and disables the send button so we don't
  // dispatch a half-built attachment.
  bool _isEncodingImage = false;
  // Tracks the most recent encoding job so a second pick (or remove)
  // overwriting a previous one doesn't surprise-update older state.
  int _encodingSequence = 0;

  late final AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _waveformController.dispose();
    unawaited(_audioRecorder.dispose());
    super.dispose();
  }

  // ───── send / receive ─────────────────────────────────────────────────

  void _handleSend() {
    final text = widget.controller.text.trim();
    final picked = _pickedImage;
    if (text.isEmpty && picked == null) return;
    // Tap arrived while base64 was still being prepared — drop the tap
    // silently. The button is also visually disabled so this mostly
    // guards against fast double-taps.
    if (_isEncodingImage) return;

    unawaited(HapticFeedback.lightImpact());
    context.read<ChatBloc>().add(
      ChatMessageSent(
        text,
        image: picked != null
            ? ChatImageAttachment(
                base64Data: picked.base64Data,
                mimeType: picked.mimeType,
              )
            : null,
        imageBytes: picked?.bytes,
      ),
    );
    widget.controller.clear();
    _clearPickedImage();
    widget.onAfterSend();
  }

  /// Clears the staged image and bumps the encoding sequence so any
  /// in-flight `_encodeImageData` completion is ignored — prevents a stale
  /// encoding from re-populating `_pickedImage` after the user already
  /// removed the attachment or sent it.
  void _clearPickedImage() {
    _encodingSequence++;
    setState(() {
      _pickedImage = null;
      _isEncodingImage = false;
    });
  }

  // ───── image attach ───────────────────────────────────────────────────

  Future<void> _pickFromSource(ImageSource source) async {
    try {
      final xfile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1920,
      );
      if (xfile == null || !mounted) return;
      final bytes = await xfile.readAsBytes();
      final mime = _mimeTypeFromName(xfile.name);

      // Snap the thumbnail in immediately with bytes only — the user gets
      // instant visual feedback while the (synchronous, expensive) base64
      // encode proceeds off-thread. `_isEncodingImage` drives a loading
      // overlay on the thumbnail and disables the send button.
      final sequence = ++_encodingSequence;
      setState(() {
        _isEncodingImage = true;
        _pickedImage = _PickedImage(
          base64Data: '',
          mimeType: mime,
          bytes: bytes,
        );
      });

      final base64 = await _encodeBase64(bytes);
      if (!mounted || sequence != _encodingSequence) return;
      // Sequence guard: if the user removed the image or picked another
      // one before this finished, drop the stale result.
      setState(() {
        _isEncodingImage = false;
        _pickedImage = _PickedImage(
          base64Data: base64,
          mimeType: mime,
          bytes: bytes,
        );
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isEncodingImage = false);
      context.showSnack('${t.chat.image.pickError}: $e');
    }
  }

  /// Runs base64 encoding off the main isolate when supported. On web
  /// there are no isolates, so we yield to the event loop and run
  /// synchronously — at least the immediate thumbnail has already painted
  /// by the time we get here.
  Future<String> _encodeBase64(Uint8List bytes) async {
    if (kIsWeb) {
      await Future<void>.delayed(Duration.zero);
      return _encodeBase64Sync(bytes);
    }
    return compute(_encodeBase64Sync, bytes);
  }

  String _mimeTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }

  Future<void> _showAttachMenu() async {
    unawaited(HapticFeedback.selectionClick());
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = sheetContext.appColors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onBackgroundLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: _AttachIcon(
                      icon: FontAwesomeIcons.camera,
                      color: colors.primary,
                    ),
                    title: Text(t.chat.image.takePhoto),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      unawaited(_pickFromSource(ImageSource.camera));
                    },
                  ),
                  ListTile(
                    leading: _AttachIcon(
                      icon: FontAwesomeIcons.image,
                      color: colors.income,
                    ),
                    title: Text(t.chat.image.fromGallery),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      unawaited(_pickFromSource(ImageSource.gallery));
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ───── audio recording ────────────────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      if (!await _ensureMicPermission()) return;
      await _audioRecorder.start();
      _beginRecordingUi();
    } on Exception catch (e, st) {
      _showRecordError(e, st);
    }
  }

  Future<bool> _ensureMicPermission() async {
    if (await _audioRecorder.hasPermission()) return true;
    if (mounted) {
      context.showSnack(t.chat.audio.permissionDenied);
    }
    return false;
  }

  void _beginRecordingUi() {
    _elapsed = Duration.zero;
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
    unawaited(_waveformController.repeat());
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    _stopRecordingUi();
    try {
      final audio = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (audio == null || !mounted) return;
      context.read<ChatBloc>().add(
        ChatAudioTranscriptionRequested(
          base64Data: audio.base64Data,
          mimeType: audio.mimeType,
        ),
      );
    } on Exception catch (e, st) {
      if (mounted) setState(() => _isRecording = false);
      _showRecordError(e, st);
    }
  }

  Future<void> _cancelRecording() async {
    _stopRecordingUi();
    await _audioRecorder.cancel();
    if (mounted) setState(() => _isRecording = false);
  }

  void _stopRecordingUi() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _waveformController.stop();
  }

  /// Raw platform errors are logged, never shown — the snackbar carries
  /// only the localized message.
  void _showRecordError(Object error, StackTrace stackTrace) {
    log(
      'ChatInput: audio recording failed',
      name: 'ChatInput',
      error: error,
      stackTrace: stackTrace,
    );
    if (!mounted) return;
    context.showSnack(t.chat.audio.recordError);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ───── build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final isTranscribing = state is ChatLoaded && state.isTranscribing;

        return Container(
          padding: EdgeInsets.fromLTRB(
            12,
            8,
            12,
            MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            border: Border(
              top: BorderSide(
                color: context.appColors.surfaceVariant,
                width: 0.5,
              ),
            ),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            child: _isRecording
                ? ChatRecordingRow(
                    elapsedLabel: _formatDuration(_elapsed),
                    onCancel: () => unawaited(_cancelRecording()),
                    onStop: () => unawaited(_stopRecording()),
                    waveformController: _waveformController,
                  )
                : isTranscribing
                    ? const ChatTranscribingRow()
                    : _DefaultRow(
                        controller: widget.controller,
                        pickedImage: _pickedImage,
                        isEncodingImage: _isEncodingImage,
                        onRemoveImage: _clearPickedImage,
                        onAttach: () => unawaited(_showAttachMenu()),
                        onSend: _handleSend,
                        onStartRecording: () => unawaited(_startRecording()),
                      ),
          ),
        );
      },
    );
  }
}

// ─── Default row ────────────────────────────────────────────────────────

class _DefaultRow extends StatelessWidget {
  const _DefaultRow({
    required this.controller,
    required this.pickedImage,
    required this.isEncodingImage,
    required this.onRemoveImage,
    required this.onAttach,
    required this.onSend,
    required this.onStartRecording,
  });

  final TextEditingController controller;
  final _PickedImage? pickedImage;
  final bool isEncodingImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final VoidCallback onStartRecording;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final picked = pickedImage;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (picked != null)
          ChatAttachmentPreview(
            bytes: picked.bytes,
            isEncoding: isEncodingImage,
            onRemove: onRemoveImage,
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _PillLeadingIcon(onAttach: onAttach),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: t.chat.placeholder,
                          hintStyle: context.textTheme.bodyMedium?.copyWith(
                            color: colors.onBackgroundLight,
                          ),
                          // The outer Container already paints the pill
                          // background — leaving `filled` on (inherited from
                          // the global theme) draws a rectangular fill that
                          // pokes through the rounded corners on the right.
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onBackground,
                          height: 1.3,
                        ),
                        cursorColor: colors.primary,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ChatMorphingTrailingButton(
              controller: controller,
              hasImage: picked != null,
              isDisabled: isEncodingImage,
              onSend: onSend,
              onStartRecording: onStartRecording,
            ),
          ],
        ),
      ],
    );
  }
}

class _PillLeadingIcon extends StatelessWidget {
  const _PillLeadingIcon({required this.onAttach});

  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IconButton(
      icon: FaIcon(
        FontAwesomeIcons.paperclip,
        color: colors.onBackgroundLight,
        size: 18,
      ),
      onPressed: onAttach,
      tooltip: t.chat.image.attach,
    );
  }
}

// ─── Attach sheet icon ──────────────────────────────────────────────────

class _AttachIcon extends StatelessWidget {
  const _AttachIcon({required this.icon, required this.color});

  final FaIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FaIcon(icon, size: 16, color: color),
      ),
    );
  }
}

class _PickedImage {
  const _PickedImage({
    required this.base64Data,
    required this.mimeType,
    required this.bytes,
  });

  final String base64Data;
  final String mimeType;
  final Uint8List bytes;
}

/// Top-level so it can be passed to [compute] (closures capturing instance
/// state aren't transferable across isolates). The base64 encode is the
/// only expensive step now — at 1920 px / quality 75 the JPEG can hit
/// ~1.5 MB, and `base64Encode` runs synchronously, so we offload it.
String _encodeBase64Sync(Uint8List bytes) => base64Encode(bytes);
