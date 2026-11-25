// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckIn {

 String get memberId; DateTime get enteredAt; DateTime get expiresAt;@JsonKey(unknownEnumValue: CheckInSource.manual) CheckInSource get source;
/// Create a copy of CheckIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInCopyWith<CheckIn> get copyWith => _$CheckInCopyWithImpl<CheckIn>(this as CheckIn, _$identity);

  /// Serializes this CheckIn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckIn&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.enteredAt, enteredAt) || other.enteredAt == enteredAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,enteredAt,expiresAt,source);

@override
String toString() {
  return 'CheckIn(memberId: $memberId, enteredAt: $enteredAt, expiresAt: $expiresAt, source: $source)';
}


}

/// @nodoc
abstract mixin class $CheckInCopyWith<$Res>  {
  factory $CheckInCopyWith(CheckIn value, $Res Function(CheckIn) _then) = _$CheckInCopyWithImpl;
@useResult
$Res call({
 String memberId, DateTime enteredAt, DateTime expiresAt,@JsonKey(unknownEnumValue: CheckInSource.manual) CheckInSource source
});




}
/// @nodoc
class _$CheckInCopyWithImpl<$Res>
    implements $CheckInCopyWith<$Res> {
  _$CheckInCopyWithImpl(this._self, this._then);

  final CheckIn _self;
  final $Res Function(CheckIn) _then;

/// Create a copy of CheckIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? enteredAt = null,Object? expiresAt = null,Object? source = null,}) {
  return _then(CheckIn(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,enteredAt: null == enteredAt ? _self.enteredAt : enteredAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CheckInSource,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckIn].
extension CheckInPatterns on CheckIn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckIn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckIn value)  $default,){
final _that = this;
switch (_that) {
case _CheckIn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckIn value)?  $default,){
final _that = this;
switch (_that) {
case _CheckIn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  DateTime enteredAt,  DateTime expiresAt, @JsonKey(unknownEnumValue: CheckInSource.manual)  CheckInSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckIn() when $default != null:
return $default(_that.memberId,_that.enteredAt,_that.expiresAt,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  DateTime enteredAt,  DateTime expiresAt, @JsonKey(unknownEnumValue: CheckInSource.manual)  CheckInSource source)  $default,) {final _that = this;
switch (_that) {
case _CheckIn():
return $default(_that.memberId,_that.enteredAt,_that.expiresAt,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  DateTime enteredAt,  DateTime expiresAt, @JsonKey(unknownEnumValue: CheckInSource.manual)  CheckInSource source)?  $default,) {final _that = this;
switch (_that) {
case _CheckIn() when $default != null:
return $default(_that.memberId,_that.enteredAt,_that.expiresAt,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckIn extends CheckIn {
  const _CheckIn({required this.memberId, required this.enteredAt, required this.expiresAt, @JsonKey(unknownEnumValue: CheckInSource.manual) required this.source}): super._();
  factory _CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);

@override final  String memberId;
@override final  DateTime enteredAt;
@override final  DateTime expiresAt;
@override@JsonKey(unknownEnumValue: CheckInSource.manual) final  CheckInSource source;

/// Create a copy of CheckIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInCopyWith<_CheckIn> get copyWith => __$CheckInCopyWithImpl<_CheckIn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckIn&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.enteredAt, enteredAt) || other.enteredAt == enteredAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,enteredAt,expiresAt,source);

@override
String toString() {
  return 'CheckIn(memberId: $memberId, enteredAt: $enteredAt, expiresAt: $expiresAt, source: $source)';
}


}

/// @nodoc
abstract mixin class _$CheckInCopyWith<$Res> implements $CheckInCopyWith<$Res> {
  factory _$CheckInCopyWith(_CheckIn value, $Res Function(_CheckIn) _then) = __$CheckInCopyWithImpl;
@override @useResult
$Res call({
 String memberId, DateTime enteredAt, DateTime expiresAt,@JsonKey(unknownEnumValue: CheckInSource.manual) CheckInSource source
});




}
/// @nodoc
class __$CheckInCopyWithImpl<$Res>
    implements _$CheckInCopyWith<$Res> {
  __$CheckInCopyWithImpl(this._self, this._then);

  final _CheckIn _self;
  final $Res Function(_CheckIn) _then;

/// Create a copy of CheckIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? enteredAt = null,Object? expiresAt = null,Object? source = null,}) {
  return _then(_CheckIn(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,enteredAt: null == enteredAt ? _self.enteredAt : enteredAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CheckInSource,
  ));
}


}

// dart format on
