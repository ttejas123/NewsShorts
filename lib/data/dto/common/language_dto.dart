import 'package:bl_inshort/core/logging/factory_safe_dto_conversion.dart';
import 'package:bl_inshort/data/models/feeds/language_entity.dart';

class LanguageDto extends FactorySafeDto<LanguageDto> {
  int? id;
  final String name;
  final String code;

  LanguageDto({required this.id, required this.name, required this.code});

  LanguageDto fromJson(Map<String, dynamic> json) {
    return LanguageDto(id: json['id'], name: json['name'], code: json['code']);
  }

  factory LanguageDto.prototype() {
    return LanguageDto(id: -1, name: "", code: "");
  }

  @override
  String toString() {
    return 'LanguageDto{id=$id, name=$name, code=$code}';
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code};
  }

  LanguageEntity toEntity() {
    return LanguageEntity(id: id, name: name, code: code);
  }
}
