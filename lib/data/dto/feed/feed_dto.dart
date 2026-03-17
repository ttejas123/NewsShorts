import 'package:bl_inshort/core/logging/factory_safe_dto_conversion.dart';
import 'package:bl_inshort/data/dto/common/Item_type_provider_dto.dart';
import 'package:bl_inshort/data/dto/common/author_dto.dart';
import 'package:bl_inshort/data/dto/common/source_dto.dart';
import 'package:bl_inshort/data/dto/common/category_dto.dart';
import 'package:bl_inshort/data/dto/common/tag_dto.dart';
import 'package:bl_inshort/data/dto/common/language_dto.dart';
import 'package:bl_inshort/data/dto/common/region_dto.dart';
import 'package:bl_inshort/data/dto/common/status_dto.dart';
import 'package:bl_inshort/data/dto/common/resource_dto.dart';
import 'package:bl_inshort/data/models/feeds/feed_entity.dart';

enum FeedLayoutType {
  photoDominant, // big image, small text
  textDominant, // more text, image secondary
  gallery, // horizontal image slider
  story, // story-like full-bleed layout
  htmlViewCard, // card with static html preview
  browserCard, // card with link to external browser
  standardCard; // card with link to external browser

  static FeedLayoutType fromString(String value) {
    return FeedLayoutType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FeedLayoutType.standardCard,
    );
  }
}

enum ItemType {
  News,
  Advertisement,
  SponsoredContent,
  Announcement;

  static ItemType fromString(String value) {
    return ItemType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ItemType.News,
    );
  }
}

class FeedDTO extends FactorySafeDto<FeedDTO> {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String slug;
  final String publishedAt;
  final bool isFeatured;
  final double engagementScore;
  final String webUrl;
  final String html;
  final ItemTypeProviderDto provider;

  final AuthorDto author;
  final SourceDto source;
  final CategoryDto category;
  final List<TagDto> tags;
  final LanguageDto language;
  final RegionDto region;
  final StatusDto status;
  final FeedLayoutType layout;
  final List<ResourceDto> resources;
  final FeedInteractionsDto interactions;

  FeedDTO({
    required this.id,
    required this.provider,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.slug,
    required this.publishedAt,
    required this.isFeatured,
    required this.engagementScore,
    required this.author,
    required this.source,
    required this.category,
    required this.tags,
    required this.language,
    required this.region,
    required this.status,
    required this.resources,
    required this.layout,
    required this.webUrl,
    required this.html,
    required this.interactions,
  });

  factory FeedDTO.fromJson(Map<String, dynamic> json) {
    return FeedDTO(
      id: json['id'],
      provider: ItemTypeProviderDto.prototype().decode(json['provider']),
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      slug: json['slug'],
      webUrl: json['web_url'],
      html: json['html'],
      publishedAt: json['published_at'],
      isFeatured: json['is_featured'],
      engagementScore: ((json['engagement_score'] ?? 0) as num).toDouble(),
      author: AuthorDto.prototype().decode(json['author']),
      layout: FeedLayoutType.fromString(json['layout']),
      source: SourceDto.prototype().decode(json['source']),
      category: CategoryDto.prototype().decode(json['category']),
      tags: (json['tags'] as List)
          .map((e) => TagDto.prototype().decode(e))
          .toList(),
      language: LanguageDto.prototype().decode(json['language']),
      region: RegionDto.prototype().decode(json['region']),
      status: StatusDto.prototype().decode(json['status']),
      resources: (json['resources'] as List)
          .map((e) => ResourceDto.prototype().decode(e))
          .toList(),
      interactions: FeedInteractionsDto.fromJson(json['interactions']),
    );
  }

  @override
  String toString() {
    return 'FeedDTO{id=$id, title=$title, subtitle=$subtitle, description=$description, slug=$slug, publishedAt=$publishedAt, isFeatured=$isFeatured, engagementScore=$engagementScore, webUrl=$webUrl, html=$html, provider=$provider, author=$author, source=$source, category=$category, tags=$tags, language=$language, region=$region, status=$status, layout=$layout, resources=$resources}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'slug': slug,
      'published_at': publishedAt,
      'is_featured': isFeatured,
      'engagement_score': engagementScore,
      'web_url': webUrl,
      'html': html,
      'provider': provider.toJson(),
      'author': author.toJson(),
      'source': source.toJson(),
      'category': category.toJson(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'language': language.toJson(),
      'region': region.toJson(),
      'status': status.toJson(),
      'layout': layout.name,
      'resources': resources.map((e) => e.toJson()).toList(),
      'interactions': interactions.toJson(),
    };
  }

  FeedEntity toEntity() {
    return FeedEntity(
      id: id,
      provider: provider.toEntity(),
      title: title,
      subtitle: subtitle,
      description: description,
      slug: slug,
      webUrl: webUrl,
      html: html,
      publishedAt: DateTime.parse(publishedAt),
      isFeatured: isFeatured,
      engagementScore: engagementScore,
      author: author.toEntity(),
      layout: layout,
      source: source.toEntity(),
      category: category.toEntity(),
      tags: tags.map((e) => e.toEntity()).toList(),
      language: language.toEntity(),
      region: region.toEntity(),
      status: status.toEntity(),
      resources: resources.map((e) => e.toEntity()).toList(),
      interactions: interactions.toEntity(),
    );
  }
}

class FeedInteractionsDto {
  final InteractionItemDto like;
  final InteractionItemDto share;
  final InteractionItemDto saved;
  final InteractionItemDto view;

  FeedInteractionsDto({
    required this.like,
    required this.share,
    required this.saved,
    required this.view,
  });

  factory FeedInteractionsDto.fromJson(Map<String, dynamic> json) {
    return FeedInteractionsDto(
      like: InteractionItemDto.fromJson(json['like']),
      share: InteractionItemDto.fromJson(json['share']),
      saved: InteractionItemDto.fromJson(json['saved']),
      view: InteractionItemDto.fromJson(json['view'] ?? {'status': false}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'like': like.toJson(),
      'share': share.toJson(),
      'saved': saved.toJson(),
      'view': view.toJson(),
    };
  }

  FeedInteractionsEntity toEntity() {
    return FeedInteractionsEntity(
      like: like.toEntity(),
      share: share.toEntity(),
      saved: saved.toEntity(),
      view: view.toEntity(),
    );
  }
}

class InteractionItemDto {
  final bool status;
  final String? timestamp;

  InteractionItemDto({required this.status, this.timestamp});

  factory InteractionItemDto.fromJson(Map<String, dynamic> json) {
    return InteractionItemDto(
      status: json['status'] ?? false,
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp,
    };
  }

  InteractionItemEntity toEntity() {
    return InteractionItemEntity(
      status: status,
      timestamp: timestamp != null ? DateTime.tryParse(timestamp!) : null,
    );
  }
}
