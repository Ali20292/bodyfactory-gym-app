// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarNote {

 String get id;@DateOnlyConverter() DateTime get date; String get label;/// `RRGGBB` or `AARRGGBB`, without a leading `#`. Null means the theme
/// picks the colour.
 String? get colorHex;
/// Create a copy of CalendarNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarNoteCopyWith<CalendarNote> get copyWith => _$CalendarNoteCopyWithImpl<CalendarNote>(this as CalendarNote, _$identity);

  /// Serializes this CalendarNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarNote&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.label, label) || other.label == label)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,label,colorHex);

@override
String toString() {
  return 'CalendarNote(id: $id, date: $date, label: $label, colorHex: $colorHex)';
}


}

/// @nodoc
abstract mixin class $CalendarNoteCopyWith<$Res>  {
  factory $CalendarNoteCopyWith(CalendarNote value, $Res Function(CalendarNote) _then) = _$CalendarNoteCopyWithImpl;
@useResult
$Res call({
 String id,@DateOnlyConverter() DateTime date, String label, String? colorHex
});




}
/// @nodoc
class _$CalendarNoteCopyWithImpl<$Res>
    implements $CalendarNoteCopyWith<$Res> {
  _$CalendarNoteCopyWithImpl(this._self, this._then);

  final CalendarNote _self;
  final $Res Function(CalendarNote) _then;

/// Create a copy of CalendarNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? label = null,Object? colorHex = freezed,}) {
  return _then(CalendarNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,colorHex: freezed == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarNote].
extension CalendarNotePatterns on CalendarNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarNote value)  $default,){
final _that = this;
switch (_that) {
case _CalendarNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarNote value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @DateOnlyConverter()  DateTime date,  String label,  String? colorHex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarNote() when $default != null:
return $default(_that.id,_that.date,_that.label,_that.colorHex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @DateOnlyConverter()  DateTime date,  String label,  String? colorHex)  $default,) {final _that = this;
switch (_that) {
case _CalendarNote():
return $default(_that.id,_that.date,_that.label,_that.colorHex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @DateOnlyConverter()  DateTime date,  String label,  String? colorHex)?  $default,) {final _that = this;
switch (_that) {
case _CalendarNote() when $default != null:
return $default(_that.id,_that.date,_that.label,_that.colorHex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarNote extends CalendarNote {
  const _CalendarNote({required this.id, @DateOnlyConverter() required this.date, required this.label, this.colorHex}): super._();
  factory _CalendarNote.fromJson(Map<String, dynamic> json) => _$CalendarNoteFromJson(json);

@override final  String id;
@override@DateOnlyConverter() final  DateTime date;
@override final  String label;
/// `RRGGBB` or `AARRGGBB`, without a leading `#`. Null means the theme
/// picks the colour.
@override final  String? colorHex;

/// Create a copy of CalendarNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarNoteCopyWith<_CalendarNote> get copyWith => __$CalendarNoteCopyWithImpl<_CalendarNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarNote&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.label, label) || other.label == label)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,label,colorHex);

@override
String toString() {
  return 'CalendarNote(id: $id, date: $date, label: $label, colorHex: $colorHex)';
}


}

/// @nodoc
abstract mixin class _$CalendarNoteCopyWith<$Res> implements $CalendarNoteCopyWith<$Res> {
  factory _$CalendarNoteCopyWith(_CalendarNote value, $Res Function(_CalendarNote) _then) = __$CalendarNoteCopyWithImpl;
@override @useResult
$Res call({
 String id,@DateOnlyConverter() DateTime date, String label, String? colorHex
});




}
/// @nodoc
class __$CalendarNoteCopyWithImpl<$Res>
    implements _$CalendarNoteCopyWith<$Res> {
  __$CalendarNoteCopyWithImpl(this._self, this._then);

  final _CalendarNote _self;
  final $Res Function(_CalendarNote) _then;

/// Create a copy of CalendarNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? label = null,Object? colorHex = freezed,}) {
  return _then(_CalendarNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,colorHex: freezed == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
