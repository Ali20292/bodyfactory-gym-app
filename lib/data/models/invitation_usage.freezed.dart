// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitationUsage {

 String get id; DateTime get usedAt;/// Null when the gym recorded the visit without a name.
 String? get guestName;
/// Create a copy of InvitationUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationUsageCopyWith<InvitationUsage> get copyWith => _$InvitationUsageCopyWithImpl<InvitationUsage>(this as InvitationUsage, _$identity);

  /// Serializes this InvitationUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationUsage&&(identical(other.id, id) || other.id == id)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&(identical(other.guestName, guestName) || other.guestName == guestName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,usedAt,guestName);

@override
String toString() {
  return 'InvitationUsage(id: $id, usedAt: $usedAt, guestName: $guestName)';
}


}

/// @nodoc
abstract mixin class $InvitationUsageCopyWith<$Res>  {
  factory $InvitationUsageCopyWith(InvitationUsage value, $Res Function(InvitationUsage) _then) = _$InvitationUsageCopyWithImpl;
@useResult
$Res call({
 String id, DateTime usedAt, String? guestName
});




}
/// @nodoc
class _$InvitationUsageCopyWithImpl<$Res>
    implements $InvitationUsageCopyWith<$Res> {
  _$InvitationUsageCopyWithImpl(this._self, this._then);

  final InvitationUsage _self;
  final $Res Function(InvitationUsage) _then;

/// Create a copy of InvitationUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? usedAt = null,Object? guestName = freezed,}) {
  return _then(InvitationUsage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,usedAt: null == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitationUsage].
extension InvitationUsagePatterns on InvitationUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitationUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitationUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitationUsage value)  $default,){
final _that = this;
switch (_that) {
case _InvitationUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitationUsage value)?  $default,){
final _that = this;
switch (_that) {
case _InvitationUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime usedAt,  String? guestName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitationUsage() when $default != null:
return $default(_that.id,_that.usedAt,_that.guestName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime usedAt,  String? guestName)  $default,) {final _that = this;
switch (_that) {
case _InvitationUsage():
return $default(_that.id,_that.usedAt,_that.guestName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime usedAt,  String? guestName)?  $default,) {final _that = this;
switch (_that) {
case _InvitationUsage() when $default != null:
return $default(_that.id,_that.usedAt,_that.guestName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitationUsage extends InvitationUsage {
  const _InvitationUsage({required this.id, required this.usedAt, this.guestName}): super._();
  factory _InvitationUsage.fromJson(Map<String, dynamic> json) => _$InvitationUsageFromJson(json);

@override final  String id;
@override final  DateTime usedAt;
/// Null when the gym recorded the visit without a name.
@override final  String? guestName;

/// Create a copy of InvitationUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationUsageCopyWith<_InvitationUsage> get copyWith => __$InvitationUsageCopyWithImpl<_InvitationUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitationUsage&&(identical(other.id, id) || other.id == id)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&(identical(other.guestName, guestName) || other.guestName == guestName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,usedAt,guestName);

@override
String toString() {
  return 'InvitationUsage(id: $id, usedAt: $usedAt, guestName: $guestName)';
}


}

/// @nodoc
abstract mixin class _$InvitationUsageCopyWith<$Res> implements $InvitationUsageCopyWith<$Res> {
  factory _$InvitationUsageCopyWith(_InvitationUsage value, $Res Function(_InvitationUsage) _then) = __$InvitationUsageCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime usedAt, String? guestName
});




}
/// @nodoc
class __$InvitationUsageCopyWithImpl<$Res>
    implements _$InvitationUsageCopyWith<$Res> {
  __$InvitationUsageCopyWithImpl(this._self, this._then);

  final _InvitationUsage _self;
  final $Res Function(_InvitationUsage) _then;

/// Create a copy of InvitationUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? usedAt = null,Object? guestName = freezed,}) {
  return _then(_InvitationUsage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,usedAt: null == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
