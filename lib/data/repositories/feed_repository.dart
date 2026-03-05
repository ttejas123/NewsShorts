import 'package:bl_inshort/data/dto/feed/feed_response_dto.dart';
import 'package:dio/dio.dart';

class FeedRepository {
  final Dio dio;

  FeedRepository(this.dio);

  Future<Map<String, dynamic>> fetchFeed({
    int? cursor,
    int limit = 20,
    List<String>? preferences,
  }) async {
    String url = "/api/feed?cursor=$cursor&limit=$limit";
    if (preferences != null && preferences.isNotEmpty) {
      url += "&pref=${preferences.join(',')}";
    }
    final response = await dio.get(url);
    return {
      'entity': FeedResponseDto.toEntityFromJson(response.data),
      'count': response.data['count'],
      'cursor': response.data['cursor'],
      'hasMore': response.data['has_more'],
    };
  }
}
