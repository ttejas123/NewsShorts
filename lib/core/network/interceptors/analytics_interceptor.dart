import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:bl_inshort/core/analytics/analytics_client.dart';

class AnalyticsInterceptor extends Interceptor {
  late final AnalyticsClient _analyticsClient;

  AnalyticsInterceptor() {
    _analyticsClient = AnalyticsClient(FirebaseAnalytics.instance);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logApiCall(response.requestOptions, response.statusCode ?? 200);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logApiCall(err.requestOptions, err.response?.statusCode ?? 500);
    super.onError(err, handler);
  }

  void _logApiCall(RequestOptions options, int statusCode) {
    final startTime = options.extra['start_time'] as int?;
    final durationMs = startTime != null ? DateTime.now().millisecondsSinceEpoch - startTime : 0;
    
    _analyticsClient.logApiCall(
      endpoint: options.path,
      method: options.method,
      statusCode: statusCode,
      durationMs: durationMs,
    );
  }
}
