import 'package:bl_inshort/data/dto/feed/feed_response_dto.dart';
import 'package:dio/dio.dart';

class FeedRepository {
  final Dio dio;

  FeedRepository(this.dio);

  Future<Map<String, dynamic>> fetchFeed() async {
    final response = await dio.get("/feed");
    return {
      'entity': FeedResponseDto.toEntityFromJson(response.data),
      'count': response.data['count'],
      'cursor': response.data['cursor'],
      'hasMore': response.data['has_more'],
    };
  }
}
