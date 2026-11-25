// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  member: Member.fromJson(json['member'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'member': instance.member,
    };
