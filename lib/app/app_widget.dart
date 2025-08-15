import 'package:app_widgets/app_widgets.dart';
import 'package:financo/app/index.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(child: const _ModularApp());
  }
}

class _ModularApp extends StatelessWidget {
  const _ModularApp();

  @override
  Widget build(BuildContext context) {
    Modular
      ..setInitialRoute(ro.loading.route)
      ..setObservers([]);
    return ModularApp(
      module: AppModule(),
      child: MaterialApp.router(
        title: AppConstants.appName,
        routerConfig: Modular.routerConfig,
        theme: AppTheme.lightTheme,
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,

        scrollBehavior: const AppScrollBehavior(),
      ),
    );
  }
}
