import 'package:dio/dio.dart';

class SysUidInterceptor extends Interceptor {
  final String? sysuid;

  SysUidInterceptor(this.sysuid);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (sysuid != null) {
      final queryParams = Map<String, dynamic>.from(options.queryParameters);
      queryParams['sysuid'] = sysuid;
      options.queryParameters = queryParams;
    }
    return handler.next(options);
  }
}
