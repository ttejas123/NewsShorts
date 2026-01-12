import 'package:bl_inshort/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve splash IMMEDIATELY
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // ✅ BLACK status bar + WHITE icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // 👈 solid black
      statusBarIconBrightness: Brightness.light, // Android (white icons)
      statusBarBrightness: Brightness.dark, // iOS (white icons)
    ),
  );

  runApp(const ProviderScope(child: App()));
}
