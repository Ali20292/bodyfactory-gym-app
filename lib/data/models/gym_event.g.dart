// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GymEvent _$GymEventFromJson(Map<String, dynamic> json) => _GymEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  startsAt: DateTime.parse(json['startsAt'] as String),
  type: $enumDecode(
    _$GymEventTypeEnumMap,
    json['type'],
    unknownValue: GymEventType.event,
  ),
  imageUrl: json['imageUrl'] as String?,
  endsAt: json['endsAt'] == null
      ? null
      : DateTime.parse(json['endsAt'] as String),
);

Map<String, dynamic> _$GymEventToJson(_GymEvent instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'startsAt': instance.startsAt.toIso8601String(),
  'type': _$GymEventTypeEnumMap[instance.type]!,
  'imageUrl': instance.imageUrl,
  'endsAt': instance.endsAt?.toIso8601String(),
};

const _$GymEventTypeEnumMap = {
  GymEventType.event: 'event',
  GymEventType.offer: 'offer',
};
