import 'package:bl_inshort/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:bl_inshort/features/settings/provider.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';


Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Custom Error Widget Builder for Widget failures (instead of the red screen of death)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
    return const Scaffold(
      body: Center(
        child: Icon(Icons.error_outline, color: Colors.red, size: 40),
      ),
    );
  };

  // Preserve splash IMMEDIATELY
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Pre-load SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // ✅ BLACK status bar + WHITE icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // 👈 solid black
      statusBarIconBrightness: Brightness.light, // Android (white icons)
      statusBarBrightness: Brightness.dark, // iOS (white icons)
    ),
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const App(),
    ),
  );
}