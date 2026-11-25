// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trainer _$TrainerFromJson(Map<String, dynamic> json) => _Trainer(
  id: json['id'] as String,
  name: json['name'] as String,
  specialties: (json['specialties'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bio: json['bio'] as String,
  photoUrl: json['photoUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TrainerToJson(_Trainer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'specialties': instance.specialties,
  'bio': instance.bio,
  'photoUrl': instance.photoUrl,
  'rating': instance.rating,
};
