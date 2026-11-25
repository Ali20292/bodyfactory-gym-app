// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GymClass {

 String get id; String get name; String get description; String get instructorName; DateTime get startsAt; int get durationMinutes; int get capacity; int get bookedCount; String get room;
/// Create a copy of GymClass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymClassCopyWith<GymClass> get copyWith => _$GymClassCopyWithImpl<GymClass>(this as GymClass, _$identity);

  /// Serializes this GymClass to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymClass&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.instructorName, instructorName) || other.instructorName == instructorName)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.bookedCount, bookedCount) || other.bookedCount == bookedCount)&&(identical(other.room, room) || other.room == room));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,instructorName,startsAt,durationMinutes,capacity,bookedCount,room);

@override
String toString() {
  return 'GymClass(id: $id, name: $name, description: $description, instructorName: $instructorName, startsAt: $startsAt, durationMinutes: $durationMinutes, capacity: $capacity, bookedCount: $bookedCount, room: $room)';
}


}

/// @nodoc
abstract mixin class $GymClassCopyWith<$Res>  {
  factory $GymClassCopyWith(GymClass value, $Res Function(GymClass) _then) = _$GymClassCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String instructorName, DateTime startsAt, int durationMinutes, int capacity, int bookedCount, String room
});




}
/// @nodoc
class _$GymClassCopyWithImpl<$Res>
    implements $GymClassCopyWith<$Res> {
  _$GymClassCopyWithImpl(this._self, this._then);

  final GymClass _self;
  final $Res Function(GymClass) _then;

/// Create a copy of GymClass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? instructorName = null,Object? startsAt = null,Object? durationMinutes = null,Object? capacity = null,Object? bookedCount = null,Object? room = null,}) {
  return _then(GymClass(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,instructorName: null == instructorName ? _self.instructorName : instructorName // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,bookedCount: null == bookedCount ? _self.bookedCount : bookedCount // ignore: cast_nullable_to_non_nullable
as int,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GymClass].
extension GymClassPatterns on GymClass {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymClass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymClass() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymClass value)  $default,){
final _that = this;
switch (_that) {
case _GymClass():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymClass value)?  $default,){
final _that = this;
switch (_that) {
case _GymClass() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String instructorName,  DateTime startsAt,  int durationMinutes,  int capacity,  int bookedCount,  String room)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymClass() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.instructorName,_that.startsAt,_that.durationMinutes,_that.capacity,_that.bookedCount,_that.room);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String instructorName,  DateTime startsAt,  int durationMinutes,  int capacity,  int bookedCount,  String room)  $default,) {final _that = this;
switch (_that) {
case _GymClass():
return $default(_that.id,_that.name,_that.description,_that.instructorName,_that.startsAt,_that.durationMinutes,_that.capacity,_that.bookedCount,_that.room);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String instructorName,  DateTime startsAt,  int durationMinutes,  int capacity,  int bookedCount,  String room)?  $default,) {final _that = this;
switch (_that) {
case _GymClass() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.instructorName,_that.startsAt,_that.durationMinutes,_that.capacity,_that.bookedCount,_that.room);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymClass extends GymClass {
  const _GymClass({required this.id, required this.name, required this.description, required this.instructorName, required this.startsAt, required this.durationMinutes, required this.capacity, required this.bookedCount, required this.room}): super._();
  factory _GymClass.fromJson(Map<String, dynamic> json) => _$GymClassFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String instructorName;
@override final  DateTime startsAt;
@override final  int durationMinutes;
@override final  int capacity;
@override final  int bookedCount;
@override final  String room;

/// Create a copy of GymClass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymClassCopyWith<_GymClass> get copyWith => __$GymClassCopyWithImpl<_GymClass>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymClassToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymClass&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.instructorName, instructorName) || other.instructorName == instructorName)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.bookedCount, bookedCount) || other.bookedCount == bookedCount)&&(identical(other.room, room) || other.room == room));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,instructorName,startsAt,durationMinutes,capacity,bookedCount,room);

@override
String toString() {
  return 'GymClass(id: $id, name: $name, description: $description, instructorName: $instructorName, startsAt: $startsAt, durationMinutes: $durationMinutes, capacity: $capacity, bookedCount: $bookedCount, room: $room)';
}


}

/// @nodoc
abstract mixin class _$GymClassCopyWith<$Res> implements $GymClassCopyWith<$Res> {
  factory _$GymClassCopyWith(_GymClass value, $Res Function(_GymClass) _then) = __$GymClassCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String instructorName, DateTime startsAt, int durationMinutes, int capacity, int bookedCount, String room
});




}
/// @nodoc
class __$GymClassCopyWithImpl<$Res>
    implements _$GymClassCopyWith<$Res> {
  __$GymClassCopyWithImpl(this._self, this._then);

  final _GymClass _self;
  final $Res Function(_GymClass) _then;

/// Create a copy of GymClass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? instructorName = null,Object? startsAt = null,Object? durationMinutes = null,Object? capacity = null,Object? bookedCount = null,Object? room = null,}) {
  return _then(_GymClass(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,instructorName: null == instructorName ? _self.instructorName : instructorName // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,bookedCount: null == bookedCount ? _self.bookedCount : bookedCount // ignore: cast_nullable_to_non_nullable
as int,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
