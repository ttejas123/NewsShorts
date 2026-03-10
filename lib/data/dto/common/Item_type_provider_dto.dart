import 'package:bl_inshort/core/logging/factory_safe_dto_conversion.dart';
import 'package:bl_inshort/data/dto/feed/feed_dto.dart';
import 'package:bl_inshort/data/models/feeds/item_type_provider_entity.dart';

class ItemTypeProviderDto extends FactorySafeDto<ItemTypeProviderDto> {
  final String name;
  final ItemType type;
  final String subType;
  final String id;

  ItemTypeProviderDto({
    required this.name,
    required this.type,
    required this.subType,
    required this.id,
  });

  ItemTypeProviderDto fromJson(Map<String, dynamic> json) {
    return ItemTypeProviderDto(
      name: json['name'],
      subType: json['subType'],
      type: ItemType.fromString(json['type']),
      id: json['id'],
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
    return {'name': name, 'type': type.name, 'subType': subType, 'id': id};
  }

  ItemTypeProviderDto copyWith({
    String? name,
    ItemType? type,
    String? subType,
    String? id,
  }) {
    return ItemTypeProviderDto(
      name: name ?? this.name,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      id: id ?? this.id,
    );
  }

  @override
  String toString() {
    return 'ItemTypeProviderDto{name: $name, type: $type, subType: $subType, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemTypeProviderDto &&
        other.name == name &&
        other.type == type &&
        other.subType == subType &&
        other.id == id;
  }

  @override
  int get hashCode {
    return name.hashCode ^ type.hashCode ^ subType.hashCode ^ id.hashCode;
  }

  ItemTypeProvider toEntity() {
    return ItemTypeProvider(name: name, type: type, id: id, subType: subType);
  }
}
