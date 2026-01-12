import 'package:bl_inshort/core/deeplink/deeplink_handler.dart';
import 'package:bl_inshort/core/navigation/routes.dart';
import 'package:bl_inshort/features/theme/theme_provider.dart';
import 'package:bl_inshort/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  Future<void> _initializeApp() async {
    // Let first frame render
    await Future.delayed(Duration.zero);

    // 👇 init heavy stuff here
    await MobileAds.instance.initialize();
    await ref.read(themeControllerProvider.notifier).loadTheme();

    FlutterNativeSplash.remove();
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

    return MaterialApp.router(
      title: 'BL News',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      routerConfig: router,
    );
  }
}
