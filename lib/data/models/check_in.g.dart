// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckIn _$CheckInFromJson(Map<String, dynamic> json) => _CheckIn(
  memberId: json['memberId'] as String,
  enteredAt: DateTime.parse(json['enteredAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  source: $enumDecode(
    _$CheckInSourceEnumMap,
    json['source'],
    unknownValue: CheckInSource.manual,
  ),
);

Map<String, dynamic> _$CheckInToJson(_CheckIn instance) => <String, dynamic>{
  'memberId': instance.memberId,
  'enteredAt': instance.enteredAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'source': _$CheckInSourceEnumMap[instance.source]!,
};

const _$CheckInSourceEnumMap = {
  CheckInSource.turnstile: 'turnstile',
  CheckInSource.frontDesk: 'frontDesk',
  CheckInSource.manual: 'manual',
};
