// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    _AttendanceRecord(
      date: const DateOnlyConverter().fromJson(json['date'] as String),
      checkInAt: json['checkInAt'] == null
          ? null
          : DateTime.parse(json['checkInAt'] as String),
      checkOutAt: json['checkOutAt'] == null
          ? null
          : DateTime.parse(json['checkOutAt'] as String),
    );

Map<String, dynamic> _$AttendanceRecordToJson(_AttendanceRecord instance) =>
    <String, dynamic>{
      'date': const DateOnlyConverter().toJson(instance.date),
      'checkInAt': instance.checkInAt?.toIso8601String(),
      'checkOutAt': instance.checkOutAt?.toIso8601String(),
    };
