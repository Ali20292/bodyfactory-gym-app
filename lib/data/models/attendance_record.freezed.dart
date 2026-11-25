// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceRecord {

@DateOnlyConverter() DateTime get date; DateTime? get checkInAt; DateTime? get checkOutAt;
/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceRecordCopyWith<AttendanceRecord> get copyWith => _$AttendanceRecordCopyWithImpl<AttendanceRecord>(this as AttendanceRecord, _$identity);

  /// Serializes this AttendanceRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceRecord&&(identical(other.date, date) || other.date == date)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt)&&(identical(other.checkOutAt, checkOutAt) || other.checkOutAt == checkOutAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,checkInAt,checkOutAt);

@override
String toString() {
  return 'AttendanceRecord(date: $date, checkInAt: $checkInAt, checkOutAt: $checkOutAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceRecordCopyWith<$Res>  {
  factory $AttendanceRecordCopyWith(AttendanceRecord value, $Res Function(AttendanceRecord) _then) = _$AttendanceRecordCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime date, DateTime? checkInAt, DateTime? checkOutAt
});




}
/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._self, this._then);

  final AttendanceRecord _self;
  final $Res Function(AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? checkInAt = freezed,Object? checkOutAt = freezed,}) {
  return _then(AttendanceRecord(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,checkInAt: freezed == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutAt: freezed == checkOutAt ? _self.checkOutAt : checkOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceRecord].
extension AttendanceRecordPatterns on AttendanceRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceRecord value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceRecord value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime date,  DateTime? checkInAt,  DateTime? checkOutAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.date,_that.checkInAt,_that.checkOutAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime date,  DateTime? checkInAt,  DateTime? checkOutAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord():
return $default(_that.date,_that.checkInAt,_that.checkOutAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime date,  DateTime? checkInAt,  DateTime? checkOutAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.date,_that.checkInAt,_that.checkOutAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceRecord extends AttendanceRecord {
  const _AttendanceRecord({@DateOnlyConverter() required this.date, this.checkInAt, this.checkOutAt}): super._();
  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);

@override@DateOnlyConverter() final  DateTime date;
@override final  DateTime? checkInAt;
@override final  DateTime? checkOutAt;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceRecordCopyWith<_AttendanceRecord> get copyWith => __$AttendanceRecordCopyWithImpl<_AttendanceRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceRecord&&(identical(other.date, date) || other.date == date)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt)&&(identical(other.checkOutAt, checkOutAt) || other.checkOutAt == checkOutAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,checkInAt,checkOutAt);

@override
String toString() {
  return 'AttendanceRecord(date: $date, checkInAt: $checkInAt, checkOutAt: $checkOutAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceRecordCopyWith<$Res> implements $AttendanceRecordCopyWith<$Res> {
  factory _$AttendanceRecordCopyWith(_AttendanceRecord value, $Res Function(_AttendanceRecord) _then) = __$AttendanceRecordCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime date, DateTime? checkInAt, DateTime? checkOutAt
});




}
/// @nodoc
class __$AttendanceRecordCopyWithImpl<$Res>
    implements _$AttendanceRecordCopyWith<$Res> {
  __$AttendanceRecordCopyWithImpl(this._self, this._then);

  final _AttendanceRecord _self;
  final $Res Function(_AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? checkInAt = freezed,Object? checkOutAt = freezed,}) {
  return _then(_AttendanceRecord(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,checkInAt: freezed == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOutAt: freezed == checkOutAt ? _self.checkOutAt : checkOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
