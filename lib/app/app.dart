import 'package:bl_inshort/core/deeplink/deeplink_handler.dart';
import 'package:bl_inshort/core/navigation/routes.dart';
import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/features/settings/provider.dart';
import 'package:bl_inshort/features/theme/theme_provider.dart';
import 'package:bl_inshort/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:bl_inshort/l10n/app_localizations.dart';

class LocalizationAdapter {
  static Locale? localeFromLanguage(LanguageEntity? lang) {
    if (lang == null) return null;
    return Locale(lang.code);
  }

  static const supportedLocales = [Locale('en'), Locale('hi'), Locale('ar')];

  static const delegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initAds() {
    unawaited(MobileAds.instance.initialize());
  }

  void _loadTheme() {
    ref.read(themeControllerProvider.notifier).loadTheme();
  }

  Future<void> _initializeApp() async {
    // Let first frame render
    await Future.delayed(Duration.zero);

    FlutterNativeSplash.remove();
    // 👇 init heavy stuff here
    _initAds();
    _loadTheme();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DeepLinkHandler.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(ref);
    final themeController = ref.watch(themeControllerProvider);
    final lang = ref.watch(settingsControllerProvider).selectedLanguage;

    return MaterialApp.router(
      title: 'BL News',
      debugShowCheckedModeBanner: false,
      locale: LocalizationAdapter.localeFromLanguage(lang),
      supportedLocales: LocalizationAdapter.supportedLocales,
      localizationsDelegates: LocalizationAdapter.delegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      routerConfig: router,
    );
  }
}
