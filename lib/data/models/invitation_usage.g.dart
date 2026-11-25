// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_usage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvitationUsage _$InvitationUsageFromJson(Map<String, dynamic> json) =>
    _InvitationUsage(
      id: json['id'] as String,
      usedAt: DateTime.parse(json['usedAt'] as String),
      guestName: json['guestName'] as String?,
    );

Map<String, dynamic> _$InvitationUsageToJson(_InvitationUsage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'usedAt': instance.usedAt.toIso8601String(),
      'guestName': instance.guestName,
    };
