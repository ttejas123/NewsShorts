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

  // Common Custom Events

  Future<void> logButtonAction({required String buttonId, String? context}) async {
    print("button clicked $buttonId");
    await FirebaseAnalytics.instance.logEvent(
      name: "test_event_123",
      parameters: {"source": "manual_test"},
    );
    await logEvent(name: 'button_clicked', parameters: {
      'button_id': buttonId,
      if (context != null) 'context': context,
    });
    print("button clicked 2 $buttonId");
  }

  Future<void> logAdFailure({
    required String adProvider,
    required String format,
    required String errorCode,
    required String errorMessage,
  }) async {
    await logEvent(name: 'ad_load_failed', parameters: {
      'provider': adProvider,
      'format': format,
      'error_code': errorCode,
      'error_message': errorMessage,
    });
  }

  Future<void> logDwellTime({required String feedId, required int durationSec}) async {
    await logEvent(name: 'feed_item_dwell_time', parameters: {
      'feed_id': feedId,
      'duration_sec': durationSec,
    });
  }

  Future<void> logSessionEnd({required int maxFeedDepth}) async {
    await logEvent(name: 'session_ended', parameters: {
      'max_feed_depth': maxFeedDepth,
    });
  }

  Future<void> logApiCall({
    required String endpoint,
    required String method,
    required int statusCode,
    required int durationMs,
  }) async {
    await logEvent(name: 'api_request', parameters: {
      'endpoint': endpoint,
      'method': method,
      'status_code': statusCode,
      'duration_ms': durationMs,
    });
  }
}

final analyticsClientProvider = Provider<AnalyticsClient>((ref) {
  return AnalyticsClient(FirebaseAnalytics.instance);
});