// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SplitTemplate _$SplitTemplateFromJson(Map<String, dynamic> json) =>
    _SplitTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      days: (json['days'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SplitTemplateToJson(_SplitTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'days': instance.days,
    };
