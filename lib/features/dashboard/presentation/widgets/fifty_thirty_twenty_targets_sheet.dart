import 'dart:async';

import 'package:financo/app/errors/failure_localizer.dart';
import 'package:financo/app/widgets/financo_submit_bar.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/features/dashboard/domain/entities/fifty_thirty_twenty_targets.dart';
import 'package:financo/features/dashboard/presentation/cubit/fifty_thirty_twenty_targets_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Modal bottom sheet for editing the user's 50/30/20 target split.
/// Lives behind a function so callers don't have to wire showModalBottomSheet
/// boilerplate. Returns when the sheet closes; the cubit's state is the
/// source of truth for the saved values.
Future<void> showFiftyThirtyTwentyTargetsSheet({
  required BuildContext context,
  required FiftyThirtyTwentyTargetsCubit cubit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: const _FiftyThirtyTwentyTargetsSheet(),
    ),
  );
}

class _FiftyThirtyTwentyTargetsSheet extends StatefulWidget {
  const _FiftyThirtyTwentyTargetsSheet();

  @override
  State<_FiftyThirtyTwentyTargetsSheet> createState() =>
      _FiftyThirtyTwentyTargetsSheetState();
}

class _FiftyThirtyTwentyTargetsSheetState
    extends State<_FiftyThirtyTwentyTargetsSheet> {
  late final TextEditingController _needsCtrl;
  late final TextEditingController _wantsCtrl;
  late final TextEditingController _savingsCtrl;
  late FiftyThirtyTwentyTargets _draft;

  @override
  void initState() {
    super.initState();
    final current = context.read<FiftyThirtyTwentyTargetsCubit>().state.targets;
    _draft = current;
    _needsCtrl = TextEditingController(text: _toPercentText(current.needs));
    _wantsCtrl = TextEditingController(text: _toPercentText(current.wants));
    _savingsCtrl = TextEditingController(text: _toPercentText(current.savings));
  }

  @override
  void dispose() {
    _needsCtrl.dispose();
    _wantsCtrl.dispose();
    _savingsCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _draft = FiftyThirtyTwentyTargets(
        needs: _fromPercentText(_needsCtrl.text),
        wants: _fromPercentText(_wantsCtrl.text),
        savings: _fromPercentText(_savingsCtrl.text),
      );
    });
  }

  void _resetToClassic() {
    setState(() {
      _draft = FiftyThirtyTwentyTargets.classic;
      _needsCtrl.text = _toPercentText(_draft.needs);
      _wantsCtrl.text = _toPercentText(_draft.wants);
      _savingsCtrl.text = _toPercentText(_draft.savings);
    });
  }

  Future<void> _submit() async {
    final cubit = context.read<FiftyThirtyTwentyTargetsCubit>();
    await cubit.submitTargets(_draft);
    if (!mounted) return;
    final state = cubit.state;
    if (state.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizedFailure(state.failure))),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isValid = _draft.isValid;
    final sumPercent = ((_draft.needs + _draft.wants + _draft.savings) * 100)
        .round();
    return BlocBuilder<FiftyThirtyTwentyTargetsCubit,
        FiftyThirtyTwentyTargetsState>(
      builder: (context, state) {
        final isSaving =
            state.status == FiftyThirtyTwentyTargetsStatus.saving;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.fiftyThirtyTwenty.editTargets,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.fiftyThirtyTwenty.editTargetsHint,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PercentField(
                    label: t.fiftyThirtyTwenty.needsLabel,
                    controller: _needsCtrl,
                    onChanged: _onChanged,
                    accent: colors.primary,
                    icon: FontAwesomeIcons.house,
                  ),
                  const SizedBox(height: 12),
                  _PercentField(
                    label: t.fiftyThirtyTwenty.wantsLabel,
                    controller: _wantsCtrl,
                    onChanged: _onChanged,
                    accent: colors.warning,
                    icon: FontAwesomeIcons.heart,
                  ),
                  const SizedBox(height: 12),
                  _PercentField(
                    label: t.fiftyThirtyTwenty.savingsLabel,
                    controller: _savingsCtrl,
                    onChanged: _onChanged,
                    accent: colors.income,
                    icon: FontAwesomeIcons.piggyBank,
                  ),
                  const SizedBox(height: 14),
                  _SumIndicator(
                    sumPercent: sumPercent,
                    isValid: isValid,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _resetToClassic,
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowRotateLeft,
                      size: 12,
                    ),
                    label: Text(t.fiftyThirtyTwenty.resetToClassic),
                  ),
                  const SizedBox(height: 8),
                  FinancoSubmitBar(
                    label: t.general.save,
                    isEnabled: isValid && !isSaving,
                    isLoading: isSaving,
                    onSubmit: () => unawaited(_submit()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Converts the canonical `[0, 1]` value into a "50", "30", "20" style
  /// integer percent string. The editor surfaces percents because that's
  /// what the user thinks in; we convert back on parse.
  String _toPercentText(double fraction) {
    return (fraction * 100).round().toString();
  }

  double _fromPercentText(String raw) {
    final cleaned = raw.replaceAll(RegExp('[^0-9]'), '');
    final value = int.tryParse(cleaned) ?? 0;
    return value / 100.0;
  }
}

class _PercentField extends StatelessWidget {
  const _PercentField({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.accent,
    required this.icon,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final Color accent;
  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(icon, size: 14, color: accent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          width: 80,
          child: TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            textAlign: TextAlign.end,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SumIndicator extends StatelessWidget {
  const _SumIndicator({required this.sumPercent, required this.isValid});

  final int sumPercent;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = isValid ? colors.success : colors.warning;
    final icon = isValid
        ? FontAwesomeIcons.circleCheck
        : FontAwesomeIcons.circleExclamation;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 13, color: tint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isValid
                  ? t.fiftyThirtyTwenty.sumOk(percent: sumPercent)
                  : t.fiftyThirtyTwenty.sumInvalid(percent: sumPercent),
              style: context.textTheme.bodySmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
