// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'split_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SplitTemplate {

 String get id; String get name; List<String> get days;
/// Create a copy of SplitTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplitTemplateCopyWith<SplitTemplate> get copyWith => _$SplitTemplateCopyWithImpl<SplitTemplate>(this as SplitTemplate, _$identity);

  /// Serializes this SplitTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplitTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.days, days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'SplitTemplate(id: $id, name: $name, days: $days)';
}


}

/// @nodoc
abstract mixin class $SplitTemplateCopyWith<$Res>  {
  factory $SplitTemplateCopyWith(SplitTemplate value, $Res Function(SplitTemplate) _then) = _$SplitTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> days
});




}
/// @nodoc
class _$SplitTemplateCopyWithImpl<$Res>
    implements $SplitTemplateCopyWith<$Res> {
  _$SplitTemplateCopyWithImpl(this._self, this._then);

  final SplitTemplate _self;
  final $Res Function(SplitTemplate) _then;

/// Create a copy of SplitTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? days = null,}) {
  return _then(SplitTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SplitTemplate].
extension SplitTemplatePatterns on SplitTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SplitTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SplitTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SplitTemplate value)  $default,){
final _that = this;
switch (_that) {
case _SplitTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SplitTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _SplitTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SplitTemplate() when $default != null:
return $default(_that.id,_that.name,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> days)  $default,) {final _that = this;
switch (_that) {
case _SplitTemplate():
return $default(_that.id,_that.name,_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> days)?  $default,) {final _that = this;
switch (_that) {
case _SplitTemplate() when $default != null:
return $default(_that.id,_that.name,_that.days);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SplitTemplate extends SplitTemplate {
  const _SplitTemplate({required this.id, required this.name, required  List<String> days}): _days = days,super._();
  factory _SplitTemplate.fromJson(Map<String, dynamic> json) => _$SplitTemplateFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _days;
@override List<String> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}


/// Create a copy of SplitTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SplitTemplateCopyWith<_SplitTemplate> get copyWith => __$SplitTemplateCopyWithImpl<_SplitTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SplitTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SplitTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._days, _days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'SplitTemplate(id: $id, name: $name, days: $days)';
}


}

/// @nodoc
abstract mixin class _$SplitTemplateCopyWith<$Res> implements $SplitTemplateCopyWith<$Res> {
  factory _$SplitTemplateCopyWith(_SplitTemplate value, $Res Function(_SplitTemplate) _then) = __$SplitTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> days
});




}
/// @nodoc
class __$SplitTemplateCopyWithImpl<$Res>
    implements _$SplitTemplateCopyWith<$Res> {
  __$SplitTemplateCopyWithImpl(this._self, this._then);

  final _SplitTemplate _self;
  final $Res Function(_SplitTemplate) _then;

/// Create a copy of SplitTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? days = null,}) {
  return _then(_SplitTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
