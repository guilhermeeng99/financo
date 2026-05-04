import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/chat/domain/entities/chat_image_attachment.dart';
import 'package:financo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Composer at the bottom of the chat. WhatsApp-inspired layout:
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
  final _recorder = AudioRecorder();
  final _imagePicker = ImagePicker();
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _tickTimer;
  String? _currentRecordingPath;
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
    unawaited(_recorder.dispose());
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.chat.image.pickError}: $e')),
      );
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
      if (!await _recorder.hasPermission()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.chat.audio.permissionDenied)),
        );
        return;
      }
      // On web, `path` is ignored by record_web (stop() returns a blob URL).
      // On mobile/desktop we write to a temp file.
      final path = kIsWeb
          ? ''
          : '${(await getTemporaryDirectory()).path}'
                '/chat_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(bitRate: 96000, numChannels: 1),
        path: path,
      );
      _currentRecordingPath = path;
      _elapsed = Duration.zero;
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
      unawaited(_waveformController.repeat());
      unawaited(HapticFeedback.mediumImpact());
      setState(() => _isRecording = true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.chat.audio.recordError}: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    _tickTimer?.cancel();
    _tickTimer = null;
    _waveformController.stop();
    final stoppedPath = await _recorder.stop() ?? _currentRecordingPath;
    setState(() => _isRecording = false);
    if (stoppedPath == null || stoppedPath.isEmpty) return;

    try {
      late final List<int> bytes;
      late final String mimeType;
      if (kIsWeb) {
        final response = await http.get(Uri.parse(stoppedPath));
        bytes = response.bodyBytes;
        mimeType = 'audio/webm';
      } else {
        final file = File(stoppedPath);
        bytes = await file.readAsBytes();
        unawaited(file.delete().catchError((_) => file));
        mimeType = 'audio/mp4';
      }
      final base64Data = base64Encode(bytes);
      if (!mounted) return;
      context.read<ChatBloc>().add(
        ChatAudioTranscriptionRequested(
          base64Data: base64Data,
          mimeType: mimeType,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.chat.audio.recordError}: $e')),
      );
    }
  }

  Future<void> _cancelRecording() async {
    _tickTimer?.cancel();
    _tickTimer = null;
    _waveformController.stop();
    final path = await _recorder.stop() ?? _currentRecordingPath;
    if (!kIsWeb && path != null && path.isNotEmpty) {
      final file = File(path);
      unawaited(file.delete().catchError((_) => file));
    }
    if (mounted) setState(() => _isRecording = false);
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
                ? _RecordingRow(
                    elapsedLabel: _formatDuration(_elapsed),
                    onCancel: () => unawaited(_cancelRecording()),
                    onStop: () => unawaited(_stopRecording()),
                    waveformController: _waveformController,
                  )
                : isTranscribing
                    ? const _TranscribingRow()
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
          _ImagePreview(
            picked: picked,
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
            _MorphingTrailingButton(
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

/// Trailing circular button that swaps icon based on whether there's
/// content to send. Watches the [TextEditingController] so the swap is
/// per-keystroke without rebuilding the whole row.
class _MorphingTrailingButton extends StatelessWidget {
  const _MorphingTrailingButton({
    required this.controller,
    required this.hasImage,
    required this.isDisabled,
    required this.onSend,
    required this.onStartRecording,
  });

  final TextEditingController controller;
  final bool hasImage;

  /// True while the picked image is still being encoded — the send
  /// pathway isn't ready yet, so the button shows a spinner and ignores
  /// taps. Mic-mode taps are also blocked, since starting a recording
  /// while encoding would race the staged attachment.
  final bool isDisabled;
  final VoidCallback onSend;
  final VoidCallback onStartRecording;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (isDisabled) {
      return SizedBox(
        width: _CircleButton._size,
        height: _CircleButton._size,
        child: Material(
          color: colors.primary.withValues(alpha: 0.6),
          shape: const CircleBorder(),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        final showSend = hasText || hasImage;
        return _CircleButton(
          icon: showSend
              ? FontAwesomeIcons.paperPlane
              : FontAwesomeIcons.microphone,
          // The mic uses the same primary fill as the send button — the
          // morph reads as "this is the action" rather than a state shift.
          color: colors.primary,
          onPressed: showSend ? onSend : onStartRecording,
          semanticLabel: showSend ? null : t.chat.audio.start,
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.iconSize = 16,
    this.semanticLabel,
  });

  static const _size = 44.0;

  final FaIconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double iconSize;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: _size,
            height: _size,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: FaIcon(
                  icon,
                  key: ValueKey(icon),
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Recording row ──────────────────────────────────────────────────────

class _RecordingRow extends StatelessWidget {
  const _RecordingRow({
    required this.elapsedLabel,
    required this.onCancel,
    required this.onStop,
    required this.waveformController,
  });

  final String elapsedLabel;
  final VoidCallback onCancel;
  final VoidCallback onStop;
  final AnimationController waveformController;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        _CircleButton(
          icon: FontAwesomeIcons.xmark,
          color: colors.surfaceVariant,
          onPressed: onCancel,
          semanticLabel: t.chat.audio.cancel,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _PulsingDot(color: colors.expense),
                const SizedBox(width: 10),
                Text(
                  elapsedLabel,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WaveformBars(controller: waveformController),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _CircleButton(
          icon: FontAwesomeIcons.solidCircleStop,
          color: colors.primary,
          onPressed: onStop,
          iconSize: 18,
          semanticLabel: t.chat.audio.stop,
        ),
      ],
    );
  }
}

/// Cheap traveling-wave visualization. Each bar's height follows a phase-
/// shifted sine so the bars look like a wave moving left-to-right.
class _WaveformBars extends StatelessWidget {
  const _WaveformBars({required this.controller});

  final AnimationController controller;

  static const _barCount = 22;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final phase = controller.value * 2 * math.pi;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_barCount, (i) {
            final x = i / (_barCount - 1);
            final h = 0.25 + 0.75 *
                (0.5 + 0.5 * math.sin(phase + x * 4 * math.pi));
            return Container(
              width: 3,
              height: 4 + h * 18,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.6 + 0.4 * h),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final t = _controller.value;
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.5 + 0.5 * t),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// ─── Transcribing row ───────────────────────────────────────────────────

class _TranscribingRow extends StatelessWidget {
  const _TranscribingRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          const SizedBox(width: 12),
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              t.chat.audio.transcribing,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onBackgroundLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Image preview ──────────────────────────────────────────────────────

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.picked,
    required this.isEncoding,
    required this.onRemove,
  });

  final _PickedImage picked;

  /// Dim the thumbnail and show a centered spinner while base64 + BlurHash
  /// are still being computed. The thumbnail itself is already painted
  /// (bytes are available) — this just signals "wait, almost ready".
  final bool isEncoding;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.memory(
                    picked.bytes,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                  if (isEncoding)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: colors.surface,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.surfaceVariant,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.xmark,
                        size: 10,
                        color: colors.onBackground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
