// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_list_series_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IssueListSeriesDto {

 String get name; int get volume;@JsonKey(name: 'year_began') int get yearBegan; int? get id;
/// Create a copy of IssueListSeriesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueListSeriesDtoCopyWith<IssueListSeriesDto> get copyWith => _$IssueListSeriesDtoCopyWithImpl<IssueListSeriesDto>(this as IssueListSeriesDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueListSeriesDto&&(identical(other.name, name) || other.name == name)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,name,volume,yearBegan,id);

@override
String toString() {
  return 'IssueListSeriesDto(name: $name, volume: $volume, yearBegan: $yearBegan, id: $id)';
}


}

/// @nodoc
abstract mixin class $IssueListSeriesDtoCopyWith<$Res>  {
  factory $IssueListSeriesDtoCopyWith(IssueListSeriesDto value, $Res Function(IssueListSeriesDto) _then) = _$IssueListSeriesDtoCopyWithImpl;
@useResult
$Res call({
 String name, int volume,@JsonKey(name: 'year_began') int yearBegan, int? id
});




}
/// @nodoc
class _$IssueListSeriesDtoCopyWithImpl<$Res>
    implements $IssueListSeriesDtoCopyWith<$Res> {
  _$IssueListSeriesDtoCopyWithImpl(this._self, this._then);

  final IssueListSeriesDto _self;
  final $Res Function(IssueListSeriesDto) _then;

/// Create a copy of IssueListSeriesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? volume = null,Object? yearBegan = null,Object? id = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int,yearBegan: null == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueListSeriesDto].
extension IssueListSeriesDtoPatterns on IssueListSeriesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueListSeriesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueListSeriesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueListSeriesDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueListSeriesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueListSeriesDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueListSeriesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int volume, @JsonKey(name: 'year_began')  int yearBegan,  int? id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueListSeriesDto() when $default != null:
return $default(_that.name,_that.volume,_that.yearBegan,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int volume, @JsonKey(name: 'year_began')  int yearBegan,  int? id)  $default,) {final _that = this;
switch (_that) {
case _IssueListSeriesDto():
return $default(_that.name,_that.volume,_that.yearBegan,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int volume, @JsonKey(name: 'year_began')  int yearBegan,  int? id)?  $default,) {final _that = this;
switch (_that) {
case _IssueListSeriesDto() when $default != null:
return $default(_that.name,_that.volume,_that.yearBegan,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _IssueListSeriesDto extends IssueListSeriesDto {
  const _IssueListSeriesDto({required this.name, required this.volume, @JsonKey(name: 'year_began') required this.yearBegan, this.id}): super._();
  

@override final  String name;
@override final  int volume;
@override@JsonKey(name: 'year_began') final  int yearBegan;
@override final  int? id;

/// Create a copy of IssueListSeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueListSeriesDtoCopyWith<_IssueListSeriesDto> get copyWith => __$IssueListSeriesDtoCopyWithImpl<_IssueListSeriesDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueListSeriesDto&&(identical(other.name, name) || other.name == name)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,name,volume,yearBegan,id);

@override
String toString() {
  return 'IssueListSeriesDto(name: $name, volume: $volume, yearBegan: $yearBegan, id: $id)';
}


}

/// @nodoc
abstract mixin class _$IssueListSeriesDtoCopyWith<$Res> implements $IssueListSeriesDtoCopyWith<$Res> {
  factory _$IssueListSeriesDtoCopyWith(_IssueListSeriesDto value, $Res Function(_IssueListSeriesDto) _then) = __$IssueListSeriesDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, int volume,@JsonKey(name: 'year_began') int yearBegan, int? id
});




}
/// @nodoc
class __$IssueListSeriesDtoCopyWithImpl<$Res>
    implements _$IssueListSeriesDtoCopyWith<$Res> {
  __$IssueListSeriesDtoCopyWithImpl(this._self, this._then);

  final _IssueListSeriesDto _self;
  final $Res Function(_IssueListSeriesDto) _then;

/// Create a copy of IssueListSeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? volume = null,Object? yearBegan = null,Object? id = freezed,}) {
  return _then(_IssueListSeriesDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int,yearBegan: null == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
