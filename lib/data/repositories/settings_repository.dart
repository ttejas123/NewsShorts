import 'package:bl_inshort/data/dto/common/language_dto.dart';
import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<LanguageEntity?> getSelectedLanguage();
  Future<void> setSelectedLanguage(LanguageEntity language);
  Future<void> setAutoplay(bool enabled);
  Future<void> setHdImages(bool enabled);
  Future<bool> isAutoplayEnabled();
  Future<bool> isHdImagesEnabled();

  Future<Set<String>> getSelectedRegions();
  Future<void> setSelectedRegions(Set<String> regions);
}

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const _languageKey = 'selected_language';
  static const _regionsKey = 'selected_regions';
  static const _autoplayKey = 'autoplay_enabled';
  static const _hdImagesKey = 'hd_images_enabled';

  final SharedPreferences _prefs;

  SharedPrefsSettingsRepository(this._prefs);

  @override
  Future<LanguageEntity?> getSelectedLanguage() async {
    final json = _prefs.getString(_languageKey);
    if (json == null) return null;
    return LanguageEntity.fromDto(
      LanguageDto.prototype().fromJson(jsonDecode(json)),
    );
  }

  @override
  Future<void> setSelectedLanguage(LanguageEntity language) async {
    await _prefs.setString(_languageKey, jsonEncode(language.toJson()));
  }

  @override
  Future<Set<String>> getSelectedRegions() async {
    return _prefs.getStringList(_regionsKey)?.toSet() ?? {};
  }

  @override
  Future<void> setSelectedRegions(Set<String> regions) async {
    await _prefs.setStringList(_regionsKey, regions.toList());
  }

  @override
  Future<bool> isAutoplayEnabled() async {
    return _prefs.getBool(_autoplayKey) ?? true;
  }

  @override
  Future<void> setAutoplay(bool enabled) async {
    await _prefs.setBool(_autoplayKey, enabled);
  }

  @override
  Future<bool> isHdImagesEnabled() async {
    return _prefs.getBool(_hdImagesKey) ?? true;
  }

  @override
  Future<void> setHdImages(bool enabled) async {
    await _prefs.setBool(_hdImagesKey, enabled);
  }
}
