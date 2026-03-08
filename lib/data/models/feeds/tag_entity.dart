import 'package:bl_inshort/data/dto/common/tag_dto.dart';

class TagEntity {
  final String id;
  final String name;

  TagEntity({
    required this.id,
    required this.name,
  });

  factory TagEntity.fromDto(TagDto dto) {
    return TagEntity(
      id: dto.id,
      name: dto.name,
    );
  }
}
