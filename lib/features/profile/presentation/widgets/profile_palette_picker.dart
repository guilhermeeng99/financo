import 'dart:async';

import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/app/theme/dark_palette_cubit.dart';
import 'package:financo/app/theme/dark_palettes.dart';
import 'package:financo/app/theme/light_palette_cubit.dart';
import 'package:financo/app/theme/light_palettes.dart';
import 'package:financo/core/extensions/context_extensions.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Shows only the swatch list relevant to the currently active theme
// brightness (light palettes when light, dark palettes when dark — also
// follows the system preference when ThemeMode.system is active).
class ProfilePalettePicker extends StatelessWidget {
  const ProfilePalettePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: context.isDarkMode
          ? const _DarkPaletteSection()
          : const _LightPaletteSection(),
    );
  }
}

class _LightPaletteSection extends StatelessWidget {
  const _LightPaletteSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LightPaletteCubit, LightPalette>(
      builder: (context, selected) {
        final option = LightPalettes.byId(selected);
        return _PaletteSection(
          icon: FontAwesomeIcons.sun,
          title: t.profile.lightPalette,
          subtitle: option.label,
          children: LightPalettes.all
              .map(
                (o) => _PaletteSwatch(
                  colors: o.colors,
                  isSelected: o.id == selected,
                  onTap: () => unawaited(
                    context.read<LightPaletteCubit>().setPalette(o.id),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DarkPaletteSection extends StatelessWidget {
  const _DarkPaletteSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DarkPaletteCubit, DarkPalette>(
      builder: (context, selected) {
        final option = DarkPalettes.byId(selected);
        return _PaletteSection(
          icon: FontAwesomeIcons.moon,
          title: t.profile.darkPalette,
          subtitle: option.label,
          children: DarkPalettes.all
              .map(
                (o) => _PaletteSwatch(
                  colors: o.colors,
                  isSelected: o.id == selected,
                  onTap: () => unawaited(
                    context.read<DarkPaletteCubit>().setPalette(o.id),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PaletteSection extends StatelessWidget {
  const _PaletteSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final FaIconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
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
                child: FaIcon(icon, size: 15, color: colors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onBackgroundLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Vertical padding gives the swatches' selection ring + drop
        // shadow room to render without being clipped by the surrounding
        // section card (which uses Clip.hardEdge for its rounded corners).
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 4),
            clipBehavior: Clip.none,
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => children[i],
          ),
        ),
      ],
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  final AppColorsData colors;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? context.appColors.primary
        : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: isSelected
                ? Icon(Icons.check, size: 16, color: colors.background)
                : null,
          ),
        ),
      ),
    );
  }
}
