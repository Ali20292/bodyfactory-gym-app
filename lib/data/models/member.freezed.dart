// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Member {

/// The gym membership ID the member logs in with. A String, not an int —
/// gyms issue IDs with prefixes and leading zeros.
 String get id; String get username;/// Already masked by the backend, e.g. `+20 1** *** 4471`. The app never
/// receives the full number.
 String get phoneMasked;/// Free text rather than an enum: the gym's tier names are a product rule
/// that has not been specified yet.
 String get membershipTier; DateTime get membershipExpiry; int get invitationsRemaining; String? get profileImageUrl;/// Defaults to [MemberRole.member], and an unrecognised value from the
/// backend falls back to it too. A new role name must never accidentally
/// grant staff tools to an ordinary member.
@JsonKey(unknownEnumValue: MemberRole.member) MemberRole get role;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.phoneMasked, phoneMasked) || other.phoneMasked == phoneMasked)&&(identical(other.membershipTier, membershipTier) || other.membershipTier == membershipTier)&&(identical(other.membershipExpiry, membershipExpiry) || other.membershipExpiry == membershipExpiry)&&(identical(other.invitationsRemaining, invitationsRemaining) || other.invitationsRemaining == invitationsRemaining)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,phoneMasked,membershipTier,membershipExpiry,invitationsRemaining,profileImageUrl,role);

@override
String toString() {
  return 'Member(id: $id, username: $username, phoneMasked: $phoneMasked, membershipTier: $membershipTier, membershipExpiry: $membershipExpiry, invitationsRemaining: $invitationsRemaining, profileImageUrl: $profileImageUrl, role: $role)';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String id, String username, String phoneMasked, String membershipTier, DateTime membershipExpiry, int invitationsRemaining, String? profileImageUrl,@JsonKey(unknownEnumValue: MemberRole.member) MemberRole role
});




}
/// @nodoc
class _$MemberCopyWithImpl<$Res>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? phoneMasked = null,Object? membershipTier = null,Object? membershipExpiry = null,Object? invitationsRemaining = null,Object? profileImageUrl = freezed,Object? role = null,}) {
  return _then(Member(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,phoneMasked: null == phoneMasked ? _self.phoneMasked : phoneMasked // ignore: cast_nullable_to_non_nullable
as String,membershipTier: null == membershipTier ? _self.membershipTier : membershipTier // ignore: cast_nullable_to_non_nullable
as String,membershipExpiry: null == membershipExpiry ? _self.membershipExpiry : membershipExpiry // ignore: cast_nullable_to_non_nullable
as DateTime,invitationsRemaining: null == invitationsRemaining ? _self.invitationsRemaining : invitationsRemaining // ignore: cast_nullable_to_non_nullable
as int,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,
  ));
}

}


/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Member value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Member value)  $default,){
final _that = this;
switch (_that) {
case _Member():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Member value)?  $default,){
final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String phoneMasked,  String membershipTier,  DateTime membershipExpiry,  int invitationsRemaining,  String? profileImageUrl, @JsonKey(unknownEnumValue: MemberRole.member)  MemberRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.username,_that.phoneMasked,_that.membershipTier,_that.membershipExpiry,_that.invitationsRemaining,_that.profileImageUrl,_that.role);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String phoneMasked,  String membershipTier,  DateTime membershipExpiry,  int invitationsRemaining,  String? profileImageUrl, @JsonKey(unknownEnumValue: MemberRole.member)  MemberRole role)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.id,_that.username,_that.phoneMasked,_that.membershipTier,_that.membershipExpiry,_that.invitationsRemaining,_that.profileImageUrl,_that.role);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String phoneMasked,  String membershipTier,  DateTime membershipExpiry,  int invitationsRemaining,  String? profileImageUrl, @JsonKey(unknownEnumValue: MemberRole.member)  MemberRole role)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.username,_that.phoneMasked,_that.membershipTier,_that.membershipExpiry,_that.invitationsRemaining,_that.profileImageUrl,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Member extends Member {
  const _Member({required this.id, required this.username, required this.phoneMasked, required this.membershipTier, required this.membershipExpiry, required this.invitationsRemaining, this.profileImageUrl, @JsonKey(unknownEnumValue: MemberRole.member) this.role = MemberRole.member}): super._();
  factory _Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

/// The gym membership ID the member logs in with. A String, not an int —
/// gyms issue IDs with prefixes and leading zeros.
@override final  String id;
@override final  String username;
/// Already masked by the backend, e.g. `+20 1** *** 4471`. The app never
/// receives the full number.
@override final  String phoneMasked;
/// Free text rather than an enum: the gym's tier names are a product rule
/// that has not been specified yet.
@override final  String membershipTier;
@override final  DateTime membershipExpiry;
@override final  int invitationsRemaining;
@override final  String? profileImageUrl;
/// Defaults to [MemberRole.member], and an unrecognised value from the
/// backend falls back to it too. A new role name must never accidentally
/// grant staff tools to an ordinary member.
@override@JsonKey(unknownEnumValue: MemberRole.member) final  MemberRole role;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCopyWith<_Member> get copyWith => __$MemberCopyWithImpl<_Member>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.phoneMasked, phoneMasked) || other.phoneMasked == phoneMasked)&&(identical(other.membershipTier, membershipTier) || other.membershipTier == membershipTier)&&(identical(other.membershipExpiry, membershipExpiry) || other.membershipExpiry == membershipExpiry)&&(identical(other.invitationsRemaining, invitationsRemaining) || other.invitationsRemaining == invitationsRemaining)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,phoneMasked,membershipTier,membershipExpiry,invitationsRemaining,profileImageUrl,role);

@override
String toString() {
  return 'Member(id: $id, username: $username, phoneMasked: $phoneMasked, membershipTier: $membershipTier, membershipExpiry: $membershipExpiry, invitationsRemaining: $invitationsRemaining, profileImageUrl: $profileImageUrl, role: $role)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String phoneMasked, String membershipTier, DateTime membershipExpiry, int invitationsRemaining, String? profileImageUrl,@JsonKey(unknownEnumValue: MemberRole.member) MemberRole role
});




}
/// @nodoc
class __$MemberCopyWithImpl<$Res>
    implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? phoneMasked = null,Object? membershipTier = null,Object? membershipExpiry = null,Object? invitationsRemaining = null,Object? profileImageUrl = freezed,Object? role = null,}) {
  return _then(_Member(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,phoneMasked: null == phoneMasked ? _self.phoneMasked : phoneMasked // ignore: cast_nullable_to_non_nullable
as String,membershipTier: null == membershipTier ? _self.membershipTier : membershipTier // ignore: cast_nullable_to_non_nullable
as String,membershipExpiry: null == membershipExpiry ? _self.membershipExpiry : membershipExpiry // ignore: cast_nullable_to_non_nullable
as DateTime,invitationsRemaining: null == invitationsRemaining ? _self.invitationsRemaining : invitationsRemaining // ignore: cast_nullable_to_non_nullable
as int,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,
  ));
}


}

// dart format on
