import 'dart:async';

import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/core/utils/date_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Compact month-stepper pill driven by [DateFilterCubit]. Used inside
/// page bodies (e.g. the Dashboard) — kept narrow so callers control the
/// surrounding alignment.
class FinancoMonthFilterPill extends StatelessWidget {
  const FinancoMonthFilterPill({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFilter = context.watch<DateFilterCubit>().state;
    final colors = context.appColors;
    final label = formatMonthYear(
      DateTime(dateFilter.year, dateFilter.month),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: FontAwesomeIcons.chevronLeft,
            onTap: () => context.read<DateFilterCubit>().previousMonth(),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          _StepperButton(
            icon: FontAwesomeIcons.chevronRight,
            onTap: () => context.read<DateFilterCubit>().nextMonth(),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FaIcon(
          icon,
          size: 12,
          color: context.appColors.onBackgroundLight,
        ),
      ),
    );
  }
}
