import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsClient {
  final FirebaseAnalytics _analytics;

  AnalyticsClient(this._analytics);

  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}

final analyticsClientProvider = Provider<AnalyticsClient>((ref) {
  return AnalyticsClient(FirebaseAnalytics.instance);
});