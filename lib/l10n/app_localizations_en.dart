// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Yalla News';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPersonalizeFeed => 'Personalize Your Feed';

  @override
  String get settingsHdImage => 'HD Image';

  @override
  String get settingsNightMode => 'Night Mode';

  @override
  String get settingsNightModeDesc => 'For better readability at night';

  @override
  String get settingsAutoplay => 'Autoplay';

  @override
  String get settingsShareApp => 'Share app';

  @override
  String get settingsRateApp => 'Rate app';

  @override
  String get settingsTerms => 'Terms & Conditions';

  @override
  String get onboardingRegionTitle => 'Select Regions';

  @override
  String get onboardingRegionDesc => 'In addition to GCC and world news which other regions would you be interested in localized news from ?';

  @override
  String get onboardingRegionNext => 'Next';

  @override
  String get selectedLanguageTitle => 'News on the go.';

  @override
  String get selectedLanguageDesc => 'We summarize and curate news\nfocused on your interests so you can\nread more quickly.';

  @override
  String get selectedLanguageNext => 'Next';
}
