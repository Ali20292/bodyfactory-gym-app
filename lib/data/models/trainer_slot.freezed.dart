// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerSlot {

 String get id; String get trainerId; DateTime get startsAt; int get durationMinutes; bool get isBooked;
/// Create a copy of TrainerSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerSlotCopyWith<TrainerSlot> get copyWith => _$TrainerSlotCopyWithImpl<TrainerSlot>(this as TrainerSlot, _$identity);

  /// Serializes this TrainerSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.isBooked, isBooked) || other.isBooked == isBooked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,startsAt,durationMinutes,isBooked);

@override
String toString() {
  return 'TrainerSlot(id: $id, trainerId: $trainerId, startsAt: $startsAt, durationMinutes: $durationMinutes, isBooked: $isBooked)';
}


}

/// @nodoc
abstract mixin class $TrainerSlotCopyWith<$Res>  {
  factory $TrainerSlotCopyWith(TrainerSlot value, $Res Function(TrainerSlot) _then) = _$TrainerSlotCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, DateTime startsAt, int durationMinutes, bool isBooked
});




}
/// @nodoc
class _$TrainerSlotCopyWithImpl<$Res>
    implements $TrainerSlotCopyWith<$Res> {
  _$TrainerSlotCopyWithImpl(this._self, this._then);

  final TrainerSlot _self;
  final $Res Function(TrainerSlot) _then;

/// Create a copy of TrainerSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? startsAt = null,Object? durationMinutes = null,Object? isBooked = null,}) {
  return _then(TrainerSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,isBooked: null == isBooked ? _self.isBooked : isBooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerSlot].
extension TrainerSlotPatterns on TrainerSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerSlot value)  $default,){
final _that = this;
switch (_that) {
case _TrainerSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerSlot value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  DateTime startsAt,  int durationMinutes,  bool isBooked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerSlot() when $default != null:
return $default(_that.id,_that.trainerId,_that.startsAt,_that.durationMinutes,_that.isBooked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  DateTime startsAt,  int durationMinutes,  bool isBooked)  $default,) {final _that = this;
switch (_that) {
case _TrainerSlot():
return $default(_that.id,_that.trainerId,_that.startsAt,_that.durationMinutes,_that.isBooked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  DateTime startsAt,  int durationMinutes,  bool isBooked)?  $default,) {final _that = this;
switch (_that) {
case _TrainerSlot() when $default != null:
return $default(_that.id,_that.trainerId,_that.startsAt,_that.durationMinutes,_that.isBooked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerSlot extends TrainerSlot {
  const _TrainerSlot({required this.id, required this.trainerId, required this.startsAt, required this.durationMinutes, required this.isBooked}): super._();
  factory _TrainerSlot.fromJson(Map<String, dynamic> json) => _$TrainerSlotFromJson(json);

@override final  String id;
@override final  String trainerId;
@override final  DateTime startsAt;
@override final  int durationMinutes;
@override final  bool isBooked;

/// Create a copy of TrainerSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerSlotCopyWith<_TrainerSlot> get copyWith => __$TrainerSlotCopyWithImpl<_TrainerSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.isBooked, isBooked) || other.isBooked == isBooked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,startsAt,durationMinutes,isBooked);

@override
String toString() {
  return 'TrainerSlot(id: $id, trainerId: $trainerId, startsAt: $startsAt, durationMinutes: $durationMinutes, isBooked: $isBooked)';
}


}

/// @nodoc
abstract mixin class _$TrainerSlotCopyWith<$Res> implements $TrainerSlotCopyWith<$Res> {
  factory _$TrainerSlotCopyWith(_TrainerSlot value, $Res Function(_TrainerSlot) _then) = __$TrainerSlotCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, DateTime startsAt, int durationMinutes, bool isBooked
});




}
/// @nodoc
class __$TrainerSlotCopyWithImpl<$Res>
    implements _$TrainerSlotCopyWith<$Res> {
  __$TrainerSlotCopyWithImpl(this._self, this._then);

  final _TrainerSlot _self;
  final $Res Function(_TrainerSlot) _then;

/// Create a copy of TrainerSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? startsAt = null,Object? durationMinutes = null,Object? isBooked = null,}) {
  return _then(_TrainerSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,isBooked: null == isBooked ? _self.isBooked : isBooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
