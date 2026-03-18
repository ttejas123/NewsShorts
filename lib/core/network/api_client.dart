import 'package:bl_inshort/core/network/interceptors/mock_interceptor.dart';
import 'package:bl_inshort/core/network/interceptors/sysuid_interceptor.dart';
import 'package:bl_inshort/core/network/interceptors/analytics_interceptor.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required bool mockMode, String? sysuid})
    : dio = Dio(
        BaseOptions(
          baseUrl: "http://54.163.60.177",
          connectTimeout: const Duration(seconds: 5),
        ),
      ) {
    dio.interceptors.add(SysUidInterceptor(sysuid));
    dio.interceptors.add(AnalyticsInterceptor());
    if (mockMode) {
      dio.interceptors.add(MockInterceptor());
    }
  }
}
