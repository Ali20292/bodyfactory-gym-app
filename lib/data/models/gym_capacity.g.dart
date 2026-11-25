// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_capacity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GymCapacity _$GymCapacityFromJson(Map<String, dynamic> json) => _GymCapacity(
  currentOccupancy: (json['currentOccupancy'] as num).toInt(),
  maxCapacity: (json['maxCapacity'] as num).toInt(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GymCapacityToJson(_GymCapacity instance) =>
    <String, dynamic>{
      'currentOccupancy': instance.currentOccupancy,
      'maxCapacity': instance.maxCapacity,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
