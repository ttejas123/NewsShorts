import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bl_inshort/core/logging/Console.dart';

class AnalyticsClient {
  final FirebaseAnalytics _analytics;

  AnalyticsClient(this._analytics);

  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> init() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      final id = await _analytics.appInstanceId;
      console.info('Analytics: Initialized. App Instance ID: $id');
    } catch (e) {
      console.error('Analytics: Initialization failed. Error: $e');
    }
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      console.info('Analytics: Logging event "$name" with parameters: $parameters');
      await _analytics.logEvent(name: name, parameters: parameters);
      console.success('Analytics: Successfully logged event "$name"');
    } catch (e, stack) {
      console.error('Analytics: FAILED to log event "$name". Error: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  // Common Custom Events

  Future<void> logButtonAction({required String buttonId, String? context}) async {
    await logEvent(name: 'button_clicked', parameters: {
      'button_id': buttonId,
      if (context != null) 'context': context,
    });
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