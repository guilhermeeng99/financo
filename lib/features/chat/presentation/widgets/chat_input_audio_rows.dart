import 'dart:math' as math;

import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/chat/presentation/widgets/chat_circle_button.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Composer row shown while a voice note is being recorded: cancel button
/// on the left, pulsing dot + timer + animated waveform in the middle,
/// stop-and-send button on the right.
class ChatRecordingRow extends StatelessWidget {
  const ChatRecordingRow({
    required this.elapsedLabel,
    required this.onCancel,
    required this.onStop,
    required this.waveformController,
    super.key,
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
        ChatCircleButton(
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
        ChatCircleButton(
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

/// Composer row shown while the recorded audio is being transcribed:
/// spinner + label. Cleared once the transcript is dispatched as a
/// regular user message.
class ChatTranscribingRow extends StatelessWidget {
  const ChatTranscribingRow({super.key});

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
