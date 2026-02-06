import 'package:bl_inshort/core/network/mock/mock_loader.dart';
import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (options.path == "/api/feed?cursor=null&limit=20") {
      final data = await loadFeedMockJson();
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: data),
      );
    }

    if (options.path == "/notification") {
      final data = await loadNotificationMockJson();
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: data),
      );
    }

    return handler.next(options);
  }
}
