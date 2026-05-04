import 'package:financo/app/theme/app_colors.dart';
import 'package:financo/app/theme/light_palettes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _lightPaletteKey = 'light_palette';

// Tracks which light-mode palette is active, persisted per device. Updates
// AppColors.light so the next theme rebuild picks up the new colors.
class LightPaletteCubit extends Cubit<LightPalette> {
  LightPaletteCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(LightPalette.indigoCloud) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final value = _prefs.getString(_lightPaletteKey);
    final palette = value == null
        ? state
        : LightPalette.values.where((p) => p.name == value).firstOrNull ??
              state;
    _apply(palette);
    if (palette != state) emit(palette);
  }

  Future<void> setPalette(LightPalette palette) async {
    await _prefs.setString(_lightPaletteKey, palette.name);
    _apply(palette);
    emit(palette);
  }

  void _apply(LightPalette palette) {
    AppColors.light = LightPalettes.byId(palette).colors;
  }
}
