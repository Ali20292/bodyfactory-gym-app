// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reservation _$ReservationFromJson(Map<String, dynamic> json) => _Reservation(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  kind: $enumDecode(
    _$ReservationKindEnumMap,
    json['kind'],
    unknownValue: ReservationKind.trainer,
  ),
  referenceId: json['referenceId'] as String,
  startsAt: DateTime.parse(json['startsAt'] as String),
  status: $enumDecode(
    _$ReservationStatusEnumMap,
    json['status'],
    unknownValue: ReservationStatus.confirmed,
  ),
);

Map<String, dynamic> _$ReservationToJson(_Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'kind': _$ReservationKindEnumMap[instance.kind]!,
      'referenceId': instance.referenceId,
      'startsAt': instance.startsAt.toIso8601String(),
      'status': _$ReservationStatusEnumMap[instance.status]!,
    };

const _$ReservationKindEnumMap = {
  ReservationKind.trainer: 'trainer',
  ReservationKind.gymClass: 'class',
};

const _$ReservationStatusEnumMap = {
  ReservationStatus.confirmed: 'confirmed',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.completed: 'completed',
};
