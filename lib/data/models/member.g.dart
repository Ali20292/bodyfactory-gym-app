// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Member _$MemberFromJson(Map<String, dynamic> json) => _Member(
  id: json['id'] as String,
  username: json['username'] as String,
  phoneMasked: json['phoneMasked'] as String,
  membershipTier: json['membershipTier'] as String,
  membershipExpiry: DateTime.parse(json['membershipExpiry'] as String),
  invitationsRemaining: (json['invitationsRemaining'] as num).toInt(),
  profileImageUrl: json['profileImageUrl'] as String?,
  role:
      $enumDecodeNullable(
        _$MemberRoleEnumMap,
        json['role'],
        unknownValue: MemberRole.member,
      ) ??
      MemberRole.member,
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'phoneMasked': instance.phoneMasked,
  'membershipTier': instance.membershipTier,
  'membershipExpiry': instance.membershipExpiry.toIso8601String(),
  'invitationsRemaining': instance.invitationsRemaining,
  'profileImageUrl': instance.profileImageUrl,
  'role': _$MemberRoleEnumMap[instance.role]!,
};

const _$MemberRoleEnumMap = {
  MemberRole.member: 'member',
  MemberRole.staff: 'staff',
};
