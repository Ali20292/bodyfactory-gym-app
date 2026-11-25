// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerSlot _$TrainerSlotFromJson(Map<String, dynamic> json) => _TrainerSlot(
  id: json['id'] as String,
  trainerId: json['trainerId'] as String,
  startsAt: DateTime.parse(json['startsAt'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  isBooked: json['isBooked'] as bool,
);

Map<String, dynamic> _$TrainerSlotToJson(_TrainerSlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainerId': instance.trainerId,
      'startsAt': instance.startsAt.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'isBooked': instance.isBooked,
    };
