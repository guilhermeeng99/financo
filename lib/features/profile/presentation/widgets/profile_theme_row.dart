import 'dart:async';

import 'package:financo/app/theme/theme_cubit.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Theme picker row. Replaces the previous `SwitchListTile` (light↔dark only)
/// with a 3-way segmented toggle that exposes Light / Dark / System — same
/// language iOS Settings uses.
class ProfileThemeRow extends StatelessWidget {
  const ProfileThemeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: FaIcon(
                        _iconFor(themeMode, context),
                        size: 15,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.profile.appearance,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FinancoPillToggle<ThemeMode>(
                selected: themeMode,
                onChanged: (mode) => unawaited(
                  context.read<ThemeCubit>().setThemeMode(mode),
                ),
                options: [
                  FinancoPillToggleOption(
                    value: ThemeMode.light,
                    label: t.profile.themeLight,
                    icon: FontAwesomeIcons.sun,
                  ),
                  FinancoPillToggleOption(
                    value: ThemeMode.dark,
                    label: t.profile.themeDark,
                    icon: FontAwesomeIcons.moon,
                  ),
                  FinancoPillToggleOption(
                    value: ThemeMode.system,
                    label: t.profile.themeSystem,
                    icon: FontAwesomeIcons.mobileScreen,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static FaIconData _iconFor(ThemeMode mode, BuildContext context) {
    return switch (mode) {
      ThemeMode.dark => FontAwesomeIcons.moon,
      ThemeMode.light => FontAwesomeIcons.sun,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? FontAwesomeIcons.moon
            : FontAwesomeIcons.sun,
    };
  }
}
