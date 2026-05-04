import 'dart:async';

import 'package:financo/app/i18n/app_locale_cubit.dart';
import 'package:financo/app/widgets/financo_pill_toggle.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Three-way locale picker: System / English / Portuguese (Brasil). Mirrors
/// the appearance row visually so the Preferences section stays cohesive.
class ProfileLanguageRow extends StatelessWidget {
  const ProfileLanguageRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<AppLocaleCubit, AppLocale?>(
      builder: (context, selected) {
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
                        FontAwesomeIcons.language,
                        size: 15,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.profile.language,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FinancoPillToggle<AppLocale?>(
                selected: selected,
                onChanged: (locale) => unawaited(
                  context.read<AppLocaleCubit>().setLocale(locale),
                ),
                options: [
                  FinancoPillToggleOption(
                    value: AppLocale.en,
                    label: t.profile.languageEnglish,
                    icon: FontAwesomeIcons.flagUsa,
                  ),
                  FinancoPillToggleOption(
                    value: AppLocale.ptBr,
                    label: t.profile.languagePortuguese,
                    icon: FontAwesomeIcons.flag,
                  ),
                  FinancoPillToggleOption(
                    value: null,
                    label: t.profile.languageSystem,
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
}
