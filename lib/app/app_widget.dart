import 'package:financo/app/di/injection_container.dart';
import 'package:financo/app/routes/app_router.dart';
import 'package:financo/app/theme/app_theme.dart';
import 'package:financo/app/theme/theme_cubit.dart';
import 'package:financo/core/constants/app_constants.dart';
import 'package:financo/core/date_filter/date_filter_cubit.dart';
import 'package:financo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:financo/features/startup/presentation/cubit/startup_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        BlocProvider.value(value: sl<DateFilterCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
