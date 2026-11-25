// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SignUpChallenge _$SignUpChallengeFromJson(Map<String, dynamic> json) =>
    _SignUpChallenge(
      challengeId: json['challengeId'] as String,
      maskedPhone: json['maskedPhone'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      attemptsRemaining: (json['attemptsRemaining'] as num).toInt(),
    );

Map<String, dynamic> _$SignUpChallengeToJson(_SignUpChallenge instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'maskedPhone': instance.maskedPhone,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'attemptsRemaining': instance.attemptsRemaining,
    };
