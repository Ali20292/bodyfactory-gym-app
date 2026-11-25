// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reservation {

 String get id; String get memberId;@JsonKey(unknownEnumValue: ReservationKind.trainer) ReservationKind get kind;/// The `TrainerSlot.id` or `GymClass.id` this reservation is against.
 String get referenceId; DateTime get startsAt;@JsonKey(unknownEnumValue: ReservationStatus.confirmed) ReservationStatus get status;
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationCopyWith<Reservation> get copyWith => _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,kind,referenceId,startsAt,status);

@override
String toString() {
  return 'Reservation(id: $id, memberId: $memberId, kind: $kind, referenceId: $referenceId, startsAt: $startsAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res>  {
  factory $ReservationCopyWith(Reservation value, $Res Function(Reservation) _then) = _$ReservationCopyWithImpl;
@useResult
$Res call({
 String id, String memberId,@JsonKey(unknownEnumValue: ReservationKind.trainer) ReservationKind kind, String referenceId, DateTime startsAt,@JsonKey(unknownEnumValue: ReservationStatus.confirmed) ReservationStatus status
});




}
/// @nodoc
class _$ReservationCopyWithImpl<$Res>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? kind = null,Object? referenceId = null,Object? startsAt = null,Object? status = null,}) {
  return _then(Reservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReservationKind,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Reservation].
extension ReservationPatterns on Reservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservation value)  $default,){
final _that = this;
switch (_that) {
case _Reservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservation value)?  $default,){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId, @JsonKey(unknownEnumValue: ReservationKind.trainer)  ReservationKind kind,  String referenceId,  DateTime startsAt, @JsonKey(unknownEnumValue: ReservationStatus.confirmed)  ReservationStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.memberId,_that.kind,_that.referenceId,_that.startsAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId, @JsonKey(unknownEnumValue: ReservationKind.trainer)  ReservationKind kind,  String referenceId,  DateTime startsAt, @JsonKey(unknownEnumValue: ReservationStatus.confirmed)  ReservationStatus status)  $default,) {final _that = this;
switch (_that) {
case _Reservation():
return $default(_that.id,_that.memberId,_that.kind,_that.referenceId,_that.startsAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId, @JsonKey(unknownEnumValue: ReservationKind.trainer)  ReservationKind kind,  String referenceId,  DateTime startsAt, @JsonKey(unknownEnumValue: ReservationStatus.confirmed)  ReservationStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.memberId,_that.kind,_that.referenceId,_that.startsAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reservation extends Reservation {
  const _Reservation({required this.id, required this.memberId, @JsonKey(unknownEnumValue: ReservationKind.trainer) required this.kind, required this.referenceId, required this.startsAt, @JsonKey(unknownEnumValue: ReservationStatus.confirmed) required this.status}): super._();
  factory _Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);

@override final  String id;
@override final  String memberId;
@override@JsonKey(unknownEnumValue: ReservationKind.trainer) final  ReservationKind kind;
/// The `TrainerSlot.id` or `GymClass.id` this reservation is against.
@override final  String referenceId;
@override final  DateTime startsAt;
@override@JsonKey(unknownEnumValue: ReservationStatus.confirmed) final  ReservationStatus status;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationCopyWith<_Reservation> get copyWith => __$ReservationCopyWithImpl<_Reservation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,kind,referenceId,startsAt,status);

@override
String toString() {
  return 'Reservation(id: $id, memberId: $memberId, kind: $kind, referenceId: $referenceId, startsAt: $startsAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res> implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(_Reservation value, $Res Function(_Reservation) _then) = __$ReservationCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId,@JsonKey(unknownEnumValue: ReservationKind.trainer) ReservationKind kind, String referenceId, DateTime startsAt,@JsonKey(unknownEnumValue: ReservationStatus.confirmed) ReservationStatus status
});




}
/// @nodoc
class __$ReservationCopyWithImpl<$Res>
    implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? kind = null,Object? referenceId = null,Object? startsAt = null,Object? status = null,}) {
  return _then(_Reservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReservationKind,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,
  ));
}


}

// dart format on
