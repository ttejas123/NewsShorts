import 'package:bl_inshort/core/logging/Console.dart';
import 'package:bl_inshort/data/dto/feed/feed_dto.dart';
import 'package:bl_inshort/data/models/feeds/author_entity.dart';
import 'package:bl_inshort/data/models/feeds/category_entity.dart';
import 'package:bl_inshort/data/models/feeds/item_type_provider_entity.dart';
import 'package:bl_inshort/data/models/feeds/language_entity.dart';
import 'package:bl_inshort/data/models/feeds/region_entity.dart';
import 'package:bl_inshort/data/models/feeds/resource_entity.dart';
import 'package:bl_inshort/data/models/feeds/source_entity.dart';
import 'package:bl_inshort/data/models/feeds/status_entity.dart';
import 'package:bl_inshort/data/models/feeds/tag_entity.dart';

class FeedEntity {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final DateTime publishedAt;
  final String slug;
  final String webUrl;
  final String html;
  final ItemTypeProvider provider;

  final AuthorEntity author;
  final SourceEntity source;
  final CategoryEntity category;
  final List<TagEntity> tags;
  final LanguageEntity language;
  final RegionEntity region;
  final FeedLayoutType layout;
  final StatusEntity status;

  final bool isFeatured;
  final double engagementScore;

  final List<ResourceEntity> resources;

  FeedEntity({
    required this.id,
    required this.provider,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.publishedAt,
    required this.slug,
    required this.author,
    required this.source,
    required this.category,
    required this.tags,
    required this.language,
    required this.region,
    required this.status,
    required this.isFeatured,
    required this.engagementScore,
    required this.resources,
    required this.layout,
    required this.webUrl,
    required this.html,
  });

  factory FeedEntity.fromDto(FeedDTO dto) {
    return FeedEntity(
      id: dto.id,
      provider: ItemTypeProvider.fromDto(dto.provider),
      title: dto.title,
      subtitle: dto.subtitle,
      description: dto.description,
      slug: dto.slug,
      webUrl: dto.webUrl,
      html: dto.html,
      publishedAt: DateTime.parse(dto.publishedAt),
      isFeatured: dto.isFeatured,
      engagementScore: dto.engagementScore,

      author: AuthorEntity.fromDto(dto.author),
      source: SourceEntity.fromDto(dto.source),
      category: CategoryEntity.fromDto(dto.category),
      tags: dto.tags.map(TagEntity.fromDto).toList(),
      language: LanguageEntity.fromDto(dto.language),
      region: RegionEntity.fromDto(dto.region),
      status: StatusEntity.fromDto(dto.status),
      resources: dto.resources.map(ResourceEntity.fromDto).toList(),
      layout: dto.layout,
    );
  }
}
