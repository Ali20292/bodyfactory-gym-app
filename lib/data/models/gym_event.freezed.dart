// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GymEvent {

 String get id; String get title; String get description; DateTime get startsAt;@JsonKey(unknownEnumValue: GymEventType.event) GymEventType get type; String? get imageUrl; DateTime? get endsAt;
/// Create a copy of GymEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymEventCopyWith<GymEvent> get copyWith => _$GymEventCopyWithImpl<GymEvent>(this as GymEvent, _$identity);

  /// Serializes this GymEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,startsAt,type,imageUrl,endsAt);

@override
String toString() {
  return 'GymEvent(id: $id, title: $title, description: $description, startsAt: $startsAt, type: $type, imageUrl: $imageUrl, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class $GymEventCopyWith<$Res>  {
  factory $GymEventCopyWith(GymEvent value, $Res Function(GymEvent) _then) = _$GymEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, DateTime startsAt,@JsonKey(unknownEnumValue: GymEventType.event) GymEventType type, String? imageUrl, DateTime? endsAt
});




}
/// @nodoc
class _$GymEventCopyWithImpl<$Res>
    implements $GymEventCopyWith<$Res> {
  _$GymEventCopyWithImpl(this._self, this._then);

  final GymEvent _self;
  final $Res Function(GymEvent) _then;

/// Create a copy of GymEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? startsAt = null,Object? type = null,Object? imageUrl = freezed,Object? endsAt = freezed,}) {
  return _then(GymEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GymEventType,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GymEvent].
extension GymEventPatterns on GymEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymEvent value)  $default,){
final _that = this;
switch (_that) {
case _GymEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymEvent value)?  $default,){
final _that = this;
switch (_that) {
case _GymEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  DateTime startsAt, @JsonKey(unknownEnumValue: GymEventType.event)  GymEventType type,  String? imageUrl,  DateTime? endsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.startsAt,_that.type,_that.imageUrl,_that.endsAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  DateTime startsAt, @JsonKey(unknownEnumValue: GymEventType.event)  GymEventType type,  String? imageUrl,  DateTime? endsAt)  $default,) {final _that = this;
switch (_that) {
case _GymEvent():
return $default(_that.id,_that.title,_that.description,_that.startsAt,_that.type,_that.imageUrl,_that.endsAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  DateTime startsAt, @JsonKey(unknownEnumValue: GymEventType.event)  GymEventType type,  String? imageUrl,  DateTime? endsAt)?  $default,) {final _that = this;
switch (_that) {
case _GymEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.startsAt,_that.type,_that.imageUrl,_that.endsAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymEvent extends GymEvent {
  const _GymEvent({required this.id, required this.title, required this.description, required this.startsAt, @JsonKey(unknownEnumValue: GymEventType.event) required this.type, this.imageUrl, this.endsAt}): super._();
  factory _GymEvent.fromJson(Map<String, dynamic> json) => _$GymEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  DateTime startsAt;
@override@JsonKey(unknownEnumValue: GymEventType.event) final  GymEventType type;
@override final  String? imageUrl;
@override final  DateTime? endsAt;

/// Create a copy of GymEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymEventCopyWith<_GymEvent> get copyWith => __$GymEventCopyWithImpl<_GymEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,startsAt,type,imageUrl,endsAt);

@override
String toString() {
  return 'GymEvent(id: $id, title: $title, description: $description, startsAt: $startsAt, type: $type, imageUrl: $imageUrl, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class _$GymEventCopyWith<$Res> implements $GymEventCopyWith<$Res> {
  factory _$GymEventCopyWith(_GymEvent value, $Res Function(_GymEvent) _then) = __$GymEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, DateTime startsAt,@JsonKey(unknownEnumValue: GymEventType.event) GymEventType type, String? imageUrl, DateTime? endsAt
});




}
/// @nodoc
class __$GymEventCopyWithImpl<$Res>
    implements _$GymEventCopyWith<$Res> {
  __$GymEventCopyWithImpl(this._self, this._then);

  final _GymEvent _self;
  final $Res Function(_GymEvent) _then;

/// Create a copy of GymEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? startsAt = null,Object? type = null,Object? imageUrl = freezed,Object? endsAt = freezed,}) {
  return _then(_GymEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GymEventType,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
