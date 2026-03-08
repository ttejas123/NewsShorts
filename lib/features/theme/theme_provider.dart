import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeController extends ChangeNotifier {
  static const themeKey = 'app_theme_mode';

  AppThemeMode _mode = AppThemeMode.light;

  AppThemeMode get mode => _mode;

  ThemeMode get themeMode => _toThemeMode(_mode);

  /// Load saved theme on app start
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(themeKey);

    _mode = AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.light,
    );

    notifyListeners();
  }

  /// Change theme from UI
  Future<void> setTheme(AppThemeMode mode) async {
    _mode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, mode.name);

    notifyListeners();
  }

  ThemeMode _toThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }
}

/// ✅ THIS is what widgets will watch
final themeControllerProvider =
    ChangeNotifierProvider<ThemeController>(
  (ref) => ThemeController(),
);