import 'package:bl_inshort/core/logging/factory_safe_dto_conversion.dart';
import 'package:bl_inshort/data/dto/feed/feed_dto.dart';
import 'package:bl_inshort/data/models/feeds/feed_entity.dart';

class FeedResponseDto extends FactorySafeDto<FeedResponseDto> {
  final String? cursor;
  final bool hasMore;
  final int count;
  final List<FeedDTO> items;

  FeedResponseDto({
    required this.cursor,
    required this.hasMore,
    required this.count,
    required this.items,
  });

  FeedResponseDto fromJson(Map<String, dynamic> json) {
    return FeedResponseDto(
      cursor: json['cursor'],
      hasMore: json['has_more'],
      count: json['count'],
      items: (json['items'] as List).map((e) => FeedDTO.fromJson(e)).toList(),
    );
  }

  factory FeedResponseDto.prototype() {
    return FeedResponseDto(cursor: "", hasMore: false, count: 0, items: []);
  }

  @override
  String toString() {
    return 'FeedResponseDto{cursor=$cursor, hasMore=$hasMore, count=$count, items=$items}';
  }

  Map<String, dynamic> toJson() {
    return {
      'cursor': cursor,
      'has_more': hasMore,
      'count': count,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  static List<FeedEntity> toEntityFromJson(Map<String, dynamic> json) {
    return FeedResponseDto.prototype()
        .fromJson(json)
        .items
        .map((dto) => dto.toEntity())
        .toList();
  }
}
