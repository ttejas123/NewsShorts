import 'package:bl_inshort/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:bl_inshort/features/settings/provider.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

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
