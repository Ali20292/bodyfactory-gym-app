// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Trainer {

 String get id; String get name; List<String> get specialties; String get bio; String? get photoUrl;/// Out of 5. Null when the trainer has no ratings yet — which is not the
/// same as a rating of zero.
 double? get rating;
/// Create a copy of Trainer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerCopyWith<Trainer> get copyWith => _$TrainerCopyWithImpl<Trainer>(this as Trainer, _$identity);

  /// Serializes this Trainer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trainer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.specialties, specialties)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(specialties),bio,photoUrl,rating);

@override
String toString() {
  return 'Trainer(id: $id, name: $name, specialties: $specialties, bio: $bio, photoUrl: $photoUrl, rating: $rating)';
}


}

/// @nodoc
abstract mixin class $TrainerCopyWith<$Res>  {
  factory $TrainerCopyWith(Trainer value, $Res Function(Trainer) _then) = _$TrainerCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> specialties, String bio, String? photoUrl, double? rating
});




}
/// @nodoc
class _$TrainerCopyWithImpl<$Res>
    implements $TrainerCopyWith<$Res> {
  _$TrainerCopyWithImpl(this._self, this._then);

  final Trainer _self;
  final $Res Function(Trainer) _then;

/// Create a copy of Trainer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? specialties = null,Object? bio = null,Object? photoUrl = freezed,Object? rating = freezed,}) {
  return _then(Trainer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self.specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Trainer].
extension TrainerPatterns on Trainer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trainer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trainer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trainer value)  $default,){
final _that = this;
switch (_that) {
case _Trainer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trainer value)?  $default,){
final _that = this;
switch (_that) {
case _Trainer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> specialties,  String bio,  String? photoUrl,  double? rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trainer() when $default != null:
return $default(_that.id,_that.name,_that.specialties,_that.bio,_that.photoUrl,_that.rating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> specialties,  String bio,  String? photoUrl,  double? rating)  $default,) {final _that = this;
switch (_that) {
case _Trainer():
return $default(_that.id,_that.name,_that.specialties,_that.bio,_that.photoUrl,_that.rating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> specialties,  String bio,  String? photoUrl,  double? rating)?  $default,) {final _that = this;
switch (_that) {
case _Trainer() when $default != null:
return $default(_that.id,_that.name,_that.specialties,_that.bio,_that.photoUrl,_that.rating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trainer extends Trainer {
  const _Trainer({required this.id, required this.name, required  List<String> specialties, required this.bio, this.photoUrl, this.rating}): _specialties = specialties,super._();
  factory _Trainer.fromJson(Map<String, dynamic> json) => _$TrainerFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _specialties;
@override List<String> get specialties {
  if (_specialties is EqualUnmodifiableListView) return _specialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialties);
}

@override final  String bio;
@override final  String? photoUrl;
/// Out of 5. Null when the trainer has no ratings yet — which is not the
/// same as a rating of zero.
@override final  double? rating;

/// Create a copy of Trainer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerCopyWith<_Trainer> get copyWith => __$TrainerCopyWithImpl<_Trainer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trainer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._specialties, _specialties)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_specialties),bio,photoUrl,rating);

@override
String toString() {
  return 'Trainer(id: $id, name: $name, specialties: $specialties, bio: $bio, photoUrl: $photoUrl, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$TrainerCopyWith<$Res> implements $TrainerCopyWith<$Res> {
  factory _$TrainerCopyWith(_Trainer value, $Res Function(_Trainer) _then) = __$TrainerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> specialties, String bio, String? photoUrl, double? rating
});




}
/// @nodoc
class __$TrainerCopyWithImpl<$Res>
    implements _$TrainerCopyWith<$Res> {
  __$TrainerCopyWithImpl(this._self, this._then);

  final _Trainer _self;
  final $Res Function(_Trainer) _then;

/// Create a copy of Trainer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? specialties = null,Object? bio = null,Object? photoUrl = freezed,Object? rating = freezed,}) {
  return _then(_Trainer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self._specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
