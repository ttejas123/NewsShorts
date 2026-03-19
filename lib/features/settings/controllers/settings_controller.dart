import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/data/repositories/settings_repository.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

enum InterestPreference { interested, notInterested, neutral }

class SettingsState {
  final LanguageEntity? selectedLanguage;
  final bool onboardingIntroCompleted;
  final bool autoplayEnabled;
  final bool hdImagesEnabled;
  final Map<String, InterestPreference> interests;
  final bool isInitialized;
  final String? sysuid;
  final String preferences;

  /// NEW
  final Set<String> selectedRegions;

  const SettingsState({
    this.selectedLanguage,
    this.autoplayEnabled = true,
    this.hdImagesEnabled = true,
    this.interests = const {},
    this.selectedRegions = const {},
    this.isInitialized = false,
    this.preferences = "",
    this.onboardingIntroCompleted = false,
    this.sysuid,
  });

  SettingsState copyWith({
    LanguageEntity? selectedLanguage,
    bool? autoplayEnabled,
    bool? hdImagesEnabled,
    Map<String, InterestPreference>? interests,
    Set<String>? selectedRegions,
    bool? isInitialized,
    bool? onboardingIntroCompleted,
    String? sysuid,
    String? preferences,
  }) {
    return SettingsState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      autoplayEnabled: autoplayEnabled ?? this.autoplayEnabled,
      hdImagesEnabled: hdImagesEnabled ?? this.hdImagesEnabled,
      interests: interests ?? this.interests,
      selectedRegions: selectedRegions ?? this.selectedRegions,
      isInitialized: isInitialized ?? this.isInitialized,
      onboardingIntroCompleted:
          onboardingIntroCompleted ?? this.onboardingIntroCompleted,
      sysuid: sysuid ?? this.sysuid,
      preferences: preferences ?? this.preferences,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  final SettingsRepository repository;

  SettingsController(this.repository) : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      repository.getSelectedLanguage(),
      repository.isAutoplayEnabled(),
      repository.isHdImagesEnabled(),
      repository.getSelectedRegions(),
      repository.isOnboardingIntroCompleted(),
      repository.getSysUid(),
      repository.getPreferences(),
      repository.getInterests(),
    ]);

    String? sysuid = results[5] as String?;
    if (sysuid == null) {
      sysuid = const Uuid().v4();
      await repository.setSysUid(sysuid);
    }

    state = state.copyWith(
      selectedLanguage: results[0] as LanguageEntity?,
      autoplayEnabled: results[1] as bool,
      hdImagesEnabled: results[2] as bool,
      selectedRegions: results[3] as Set<String>,
      isInitialized: true,
      onboardingIntroCompleted: results[4] as bool,
      sysuid: sysuid,
      preferences: results[6] as String,
      interests: (results[7] as Map<String, String>).map(
        (key, value) => MapEntry(
          key,
          InterestPreference.values.firstWhere(
            (e) => e.name == value,
            orElse: () => InterestPreference.neutral,
          ),
        ),
      ),
    );
  }

  // 🔹 Language
  Future<void> selectLanguage(LanguageEntity language) async {
    await repository.setSelectedLanguage(language);
    state = state.copyWith(selectedLanguage: language);
  }

  Future<void> setSelectedRegions(Set<String> regions) async {
    await repository.setSelectedRegions(regions);
    state = state.copyWith(selectedRegions: regions);
  }

  // 🔹 Regions
  Future<void> toggleRegion(String region) async {
    final updated = Set<String>.from(state.selectedRegions);

    if (updated.contains(region)) {
      updated.remove(region);
    } else {
      updated.add(region);
    }

    await repository.setSelectedRegions(updated);
    state = state.copyWith(selectedRegions: updated);
  }

  // 🔹 Autoplay
  Future<void> setAutoplay(bool enabled) async {
    await repository.setAutoplay(enabled);
    state = state.copyWith(autoplayEnabled: enabled);
  }

  // 🔹 HD Images
  Future<void> setHdImages(bool enabled) async {
    await repository.setHdImages(enabled);
    state = state.copyWith(hdImagesEnabled: enabled);
  }

  // 🔹 Content Interest
  Future<void> setInterest(String topic, InterestPreference preference) async {
    final updated = Map<String, InterestPreference>.from(state.interests);
    updated[topic] = preference;

    state = state.copyWith(interests: updated);

    // Persist as map of strings
    final persistenceMap = updated.map((key, value) => MapEntry(key, value.name));
    await repository.setInterests(persistenceMap);
  }

  Future<void> togglePreference(String topic) async {
    final List<String> currentPrefs = state.preferences.isEmpty
        ? []
        : state.preferences.split(',').map((e) => e.trim()).toList();

    if (currentPrefs.contains(topic)) {
      currentPrefs.remove(topic);
    } else {
      currentPrefs.add(topic);
    }

    final newPrefsString = currentPrefs.join(',');
    state = state.copyWith(preferences: newPrefsString);
    await repository.setPreferences(newPrefsString);
  }

  bool isTopicSelected(String topic) {
    if (state.preferences.isEmpty) return false;
    return state.preferences.split(',').map((e) => e.trim()).contains(topic);
  }

  InterestPreference getTopicPreference(String topic) {
    return state.interests[topic] ?? InterestPreference.neutral;
  }

  bool isTopicInterested(String topic) {
    return getTopicPreference(topic) == InterestPreference.interested;
  }

  bool isTopicNotInterested(String topic) {
    return getTopicPreference(topic) == InterestPreference.notInterested;
  }

  bool isRegionSelected(String region) {
    return state.selectedRegions.contains(region);
  }

  bool get hasCompletedOnboarding =>
      state.selectedLanguage != null && state.selectedRegions.isNotEmpty;

  Future<void> setOnboardingIntroCompleted(bool completed) async {
    await repository.setOnboardingIntroCompleted(completed);
    state = state.copyWith(onboardingIntroCompleted: completed);
  }
}
