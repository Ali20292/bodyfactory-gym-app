// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarNote _$CalendarNoteFromJson(Map<String, dynamic> json) =>
    _CalendarNote(
      id: json['id'] as String,
      date: const DateOnlyConverter().fromJson(json['date'] as String),
      label: json['label'] as String,
      colorHex: json['colorHex'] as String?,
    );

Map<String, dynamic> _$CalendarNoteToJson(_CalendarNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': const DateOnlyConverter().toJson(instance.date),
      'label': instance.label,
      'colorHex': instance.colorHex,
    };
