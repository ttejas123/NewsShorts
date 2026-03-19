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
import 'package:bl_inshort/core/analytics/analytics_client.dart';
import 'package:bl_inshort/features/feed/providers.dart';

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

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Session ended or app backgrounded
      final maxDepth = ref.read(currentFeedIndexProvider);
      ref.read(analyticsClientProvider).logSessionEnd(maxFeedDepth: maxDepth);
    }
  }

  void _initAds() {
    unawaited(MobileAds.instance.initialize());
  }

  void _loadTheme() {
    ref.read(themeControllerProvider.notifier).loadTheme();
  }

  void _initAnalytics() {
    unawaited(ref.read(analyticsClientProvider).init());
  }

  Future<void> _initializeApp() async {
    // Let first frame render
    await Future.delayed(Duration.zero);

    FlutterNativeSplash.remove();
    // 👇 init heavy stuff here
    _initAds();
    _loadTheme();
    _initAnalytics();
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
