import 'package:bl_inshort/data/repositories/settings_repository.dart';
import 'package:bl_inshort/features/settings/controllers/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/legacy.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsSettingsRepository(prefs);
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      final repo = ref.read(settingsRepositoryProvider);
      return SettingsController(repo);
    });
