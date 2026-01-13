import 'package:bl_inshort/core/network/interceptors/mock_interceptor.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required bool mockMode})
    : dio = Dio(
        BaseOptions(
          baseUrl: "http://localhost:3000",
          connectTimeout: const Duration(seconds: 5),
        ),
      ) {
    if (mockMode) {
      dio.interceptors.add(MockInterceptor());
    }
  }
}
