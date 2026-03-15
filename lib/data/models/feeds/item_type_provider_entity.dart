import 'package:bl_inshort/data/dto/common/Item_type_provider_dto.dart';
import 'package:bl_inshort/data/dto/feed/feed_dto.dart';

class ItemTypeProvider {
  final String name;
  final ItemType type;
  final String subType;
  final String id;
  final String? imageUrl;
  final String? redirectUrl;

  ItemTypeProvider({
    required this.name,
    required this.type,
    required this.subType,
    required this.id,
    this.imageUrl,
    this.redirectUrl,
  });

  factory ItemTypeProvider.fromDto(ItemTypeProviderDto dto) {
    return ItemTypeProvider(
      name: dto.name,
      type: dto.type,
      subType: dto.subType,
      id: dto.id,
      imageUrl: dto.imageUrl,
      redirectUrl: dto.redirectUrl,
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

  ItemTypeProvider copyWith({
    String? name,
    ItemType? type,
    String? subType,
    String? id,
    String? imageUrl,
    String? redirectUrl,
  }) {
    return ItemTypeProvider(
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
    return 'ItemTypeProvider{name: $name, type: $type, subType: $subType, id: $id, imageUrl: $imageUrl, redirectUrl: $redirectUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemTypeProvider &&
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
}
