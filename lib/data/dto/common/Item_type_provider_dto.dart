import 'package:bl_inshort/core/logging/factory_safe_dto_conversion.dart';
import 'package:bl_inshort/data/dto/feed/feed_dto.dart';
import 'package:bl_inshort/data/models/feeds/item_type_provider_entity.dart';

class ItemTypeProviderDto extends FactorySafeDto<ItemTypeProviderDto> {
  final String name;
  final ItemType type;
  final String subType;
  final String id;
  final String? imageUrl;
  final String? redirectUrl;

  ItemTypeProviderDto({
    required this.name,
    required this.type,
    required this.subType,
    required this.id,
    this.imageUrl,
    this.redirectUrl,
  });

  ItemTypeProviderDto fromJson(Map<String, dynamic> json) {
    return ItemTypeProviderDto(
      name: json['name'],
      subType: json['subType'],
      type: ItemType.fromString(json['type']),
      id: json['id'],
      imageUrl: json['imageUrl'] as String?,
      redirectUrl: json['redirectUrl'] as String?,
    );
  }

  factory ItemTypeProviderDto.prototype() {
    return ItemTypeProviderDto(
      name: "",
      subType: "",
      type: ItemType.News,
      id: "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'subType': subType,
      'id': id,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (redirectUrl != null) 'redirectUrl': redirectUrl,
    };
  }

  ItemTypeProviderDto copyWith({
    String? name,
    ItemType? type,
    String? subType,
    String? id,
    String? imageUrl,
    String? redirectUrl,
  }) {
    return ItemTypeProviderDto(
      name: name ?? this.name,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      redirectUrl: redirectUrl ?? this.redirectUrl,
    );
  }

  @override
  String toString() {
    return 'ItemTypeProviderDto{name: $name, type: $type, subType: $subType, id: $id, imageUrl: $imageUrl, redirectUrl: $redirectUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemTypeProviderDto &&
        other.name == name &&
        other.type == type &&
        other.subType == subType &&
        other.id == id &&
        other.imageUrl == imageUrl &&
        other.redirectUrl == redirectUrl;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        type.hashCode ^
        subType.hashCode ^
        id.hashCode ^
        imageUrl.hashCode ^
        redirectUrl.hashCode;
  }

  ItemTypeProvider toEntity() {
    return ItemTypeProvider(
      name: name,
      type: type,
      id: id,
      subType: subType,
      imageUrl: imageUrl,
      redirectUrl: redirectUrl,
    );
  }
}
