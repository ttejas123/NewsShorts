import 'package:bl_inshort/data/dto/feed/feed_response_dto.dart';
import 'package:dio/dio.dart';

class FeedRepository {
  final Dio dio;

  FeedRepository(this.dio);

  Future<Map<String, dynamic>> fetchFeed({
    int? cursor,
    int limit = 20,
    String lang = "en",
  }) async {
    final response = await dio.get("/api/feed?cursor=$cursor&limit=$limit&lang=$lang");
    return {
      'entity': FeedResponseDto.toEntityFromJson(response.data),
      'count': response.data['count'],
      'cursor': response.data['cursor'],
      'hasMore': response.data['has_more'],
    };
  }

  Future<void> toggleUserAction({
    required String feedId,
    required String actionType,
  }) async {
    await dio.post(
      '/api/user-actions/toggle',
      data: {
        'feed_id': feedId,
        'action_type': actionType,
      },
    );
  }
}
