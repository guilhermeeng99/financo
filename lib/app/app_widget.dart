import 'package:financo/app/di/injection_container.dart';
import 'package:financo/app/i18n/app_locale_cubit.dart';
import 'package:financo/app/routes/app_router.dart';
import 'package:financo/app/theme/app_theme.dart';
import 'package:financo/app/theme/dark_palette_cubit.dart';
import 'package:financo/app/theme/dark_palettes.dart';
import 'package:financo/app/theme/light_palette_cubit.dart';
import 'package:financo/app/theme/light_palettes.dart';
import 'package:financo/app/theme/theme_cubit.dart';
import 'package:financo/core/constants/app_constants.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/startup/presentation/cubit/startup_cubit.dart';
import 'package:financo/gen/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

class FinancoApp extends StatefulWidget {
  const FinancoApp({super.key});

  @override
  State<FinancoApp> createState() => _FinancoAppState();
}

class _FinancoAppState extends State<FinancoApp> {
  late final GoRouter _router = createRouter(sl<AuthBloc>());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<StartupCubit>()),
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<LightPaletteCubit>()),
        BlocProvider.value(value: sl<DarkPaletteCubit>()),
        BlocProvider.value(value: sl<AppLocaleCubit>()),
        BlocProvider.value(value: sl<DateFilterCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LightPaletteCubit, LightPalette>(
            builder: (context, _) {
              return BlocBuilder<DarkPaletteCubit, DarkPalette>(
                builder: (context, _) {
                  return BlocBuilder<AppLocaleCubit, AppLocale?>(
                    builder: (context, _) {
                      // Keying off the active locale forces a full rebuild
                      // of the widget tree below MaterialApp on language
                      // switch — needed because cached page widgets
                      // (FinancoLargeAppBar titles in particular) capture
                      // their string values at construction time.
                      final activeLocale =
                          TranslationProvider.of(context).flutterLocale;
                      return MaterialApp.router(
                        key: ValueKey(activeLocale.toLanguageTag()),
                        title: AppConstants.appName,
                        debugShowCheckedModeBanner: false,
                        theme: AppTheme.light(),
                        darkTheme: AppTheme.dark(),
                        themeMode: themeMode,
                        locale: activeLocale,
                        supportedLocales: AppLocaleUtils.supportedLocales,
                        localizationsDelegates: const [
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        routerConfig: _router,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
