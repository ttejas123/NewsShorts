import 'package:bl_inshort/core/logging/factory_safe_dto_conversion.dart';
import 'package:bl_inshort/data/models/feeds/tag_entity.dart';

class TagDto extends FactorySafeDto<TagDto> {
  final String id;
  final String name;

  TagDto({required this.id, required this.name});

  TagDto fromJson(Map<String, dynamic> json) {
    return TagDto(id: json['id'], name: json['name']);
  }

  factory TagDto.prototype() {
    return TagDto(id: "", name: "");
  }

  @override
  String toString() {
    return 'TagDto{id=$id, name=$name}';
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  TagEntity toEntity() {
    return TagEntity(id: id, name: name);
  }
}
