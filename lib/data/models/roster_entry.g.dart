// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roster_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RosterEntry _$RosterEntryFromJson(Map<String, dynamic> json) => _RosterEntry(
  memberId: json['memberId'] as String,
  username: json['username'] as String,
  bookedAt: DateTime.parse(json['bookedAt'] as String),
);

Map<String, dynamic> _$RosterEntryToJson(_RosterEntry instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'username': instance.username,
      'bookedAt': instance.bookedAt.toIso8601String(),
    };
