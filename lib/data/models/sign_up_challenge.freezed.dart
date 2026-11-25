// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignUpChallenge {

/// Opaque handle for this attempt. Carries no membership information.
 String get challengeId;/// Masked by the backend, e.g. `+20 1** *** 4471`, so the user knows which
/// phone to check without the app ever holding the real number.
 String get maskedPhone; DateTime get expiresAt;/// Wrong-code attempts left before the backend locks the challenge.
 int get attemptsRemaining;
/// Create a copy of SignUpChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpChallengeCopyWith<SignUpChallenge> get copyWith => _$SignUpChallengeCopyWithImpl<SignUpChallenge>(this as SignUpChallenge, _$identity);

  /// Serializes this SignUpChallenge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpChallenge&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.attemptsRemaining, attemptsRemaining) || other.attemptsRemaining == attemptsRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,maskedPhone,expiresAt,attemptsRemaining);

@override
String toString() {
  return 'SignUpChallenge(challengeId: $challengeId, maskedPhone: $maskedPhone, expiresAt: $expiresAt, attemptsRemaining: $attemptsRemaining)';
}


}

/// @nodoc
abstract mixin class $SignUpChallengeCopyWith<$Res>  {
  factory $SignUpChallengeCopyWith(SignUpChallenge value, $Res Function(SignUpChallenge) _then) = _$SignUpChallengeCopyWithImpl;
@useResult
$Res call({
 String challengeId, String maskedPhone, DateTime expiresAt, int attemptsRemaining
});




}
/// @nodoc
class _$SignUpChallengeCopyWithImpl<$Res>
    implements $SignUpChallengeCopyWith<$Res> {
  _$SignUpChallengeCopyWithImpl(this._self, this._then);

  final SignUpChallenge _self;
  final $Res Function(SignUpChallenge) _then;

/// Create a copy of SignUpChallenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challengeId = null,Object? maskedPhone = null,Object? expiresAt = null,Object? attemptsRemaining = null,}) {
  return _then(SignUpChallenge(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,maskedPhone: null == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,attemptsRemaining: null == attemptsRemaining ? _self.attemptsRemaining : attemptsRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SignUpChallenge].
extension SignUpChallengePatterns on SignUpChallenge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpChallenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpChallenge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpChallenge value)  $default,){
final _that = this;
switch (_that) {
case _SignUpChallenge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpChallenge value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpChallenge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String challengeId,  String maskedPhone,  DateTime expiresAt,  int attemptsRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpChallenge() when $default != null:
return $default(_that.challengeId,_that.maskedPhone,_that.expiresAt,_that.attemptsRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String challengeId,  String maskedPhone,  DateTime expiresAt,  int attemptsRemaining)  $default,) {final _that = this;
switch (_that) {
case _SignUpChallenge():
return $default(_that.challengeId,_that.maskedPhone,_that.expiresAt,_that.attemptsRemaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String challengeId,  String maskedPhone,  DateTime expiresAt,  int attemptsRemaining)?  $default,) {final _that = this;
switch (_that) {
case _SignUpChallenge() when $default != null:
return $default(_that.challengeId,_that.maskedPhone,_that.expiresAt,_that.attemptsRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignUpChallenge extends SignUpChallenge {
  const _SignUpChallenge({required this.challengeId, required this.maskedPhone, required this.expiresAt, required this.attemptsRemaining}): super._();
  factory _SignUpChallenge.fromJson(Map<String, dynamic> json) => _$SignUpChallengeFromJson(json);

/// Opaque handle for this attempt. Carries no membership information.
@override final  String challengeId;
/// Masked by the backend, e.g. `+20 1** *** 4471`, so the user knows which
/// phone to check without the app ever holding the real number.
@override final  String maskedPhone;
@override final  DateTime expiresAt;
/// Wrong-code attempts left before the backend locks the challenge.
@override final  int attemptsRemaining;

/// Create a copy of SignUpChallenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpChallengeCopyWith<_SignUpChallenge> get copyWith => __$SignUpChallengeCopyWithImpl<_SignUpChallenge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignUpChallengeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpChallenge&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.attemptsRemaining, attemptsRemaining) || other.attemptsRemaining == attemptsRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,maskedPhone,expiresAt,attemptsRemaining);

@override
String toString() {
  return 'SignUpChallenge(challengeId: $challengeId, maskedPhone: $maskedPhone, expiresAt: $expiresAt, attemptsRemaining: $attemptsRemaining)';
}


}

/// @nodoc
abstract mixin class _$SignUpChallengeCopyWith<$Res> implements $SignUpChallengeCopyWith<$Res> {
  factory _$SignUpChallengeCopyWith(_SignUpChallenge value, $Res Function(_SignUpChallenge) _then) = __$SignUpChallengeCopyWithImpl;
@override @useResult
$Res call({
 String challengeId, String maskedPhone, DateTime expiresAt, int attemptsRemaining
});




}
/// @nodoc
class __$SignUpChallengeCopyWithImpl<$Res>
    implements _$SignUpChallengeCopyWith<$Res> {
  __$SignUpChallengeCopyWithImpl(this._self, this._then);

  final _SignUpChallenge _self;
  final $Res Function(_SignUpChallenge) _then;

/// Create a copy of SignUpChallenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challengeId = null,Object? maskedPhone = null,Object? expiresAt = null,Object? attemptsRemaining = null,}) {
  return _then(_SignUpChallenge(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,maskedPhone: null == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,attemptsRemaining: null == attemptsRemaining ? _self.attemptsRemaining : attemptsRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
