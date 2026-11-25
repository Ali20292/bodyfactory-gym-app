// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GymClass _$GymClassFromJson(Map<String, dynamic> json) => _GymClass(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  instructorName: json['instructorName'] as String,
  startsAt: DateTime.parse(json['startsAt'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  capacity: (json['capacity'] as num).toInt(),
  bookedCount: (json['bookedCount'] as num).toInt(),
  room: json['room'] as String,
);

Map<String, dynamic> _$GymClassToJson(_GymClass instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'instructorName': instance.instructorName,
  'startsAt': instance.startsAt.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'capacity': instance.capacity,
  'bookedCount': instance.bookedCount,
  'room': instance.room,
};
