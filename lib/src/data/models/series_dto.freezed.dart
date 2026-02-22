// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'series_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeriesDto {

@HiveField(0) int? get id;@HiveField(1) String? get name;@HiveField(2) int? get volume;@HiveField(3)@JsonKey(name: 'year_began') int? get yearBegan;@HiveField(4)@JsonKey(name: 'publisher_name') String? get publisherName;@HiveField(5)@JsonKey(name: 'desc') String? get description;@HiveField(6)@JsonKey(name: 'series') String? get seriesName;
/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesDtoCopyWith<SeriesDto> get copyWith => _$SeriesDtoCopyWithImpl<SeriesDto>(this as SeriesDto, _$identity);

  /// Serializes this SeriesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName)&&(identical(other.description, description) || other.description == description)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,volume,yearBegan,publisherName,description,seriesName);

@override
String toString() {
  return 'SeriesDto(id: $id, name: $name, volume: $volume, yearBegan: $yearBegan, publisherName: $publisherName, description: $description, seriesName: $seriesName)';
}


}

/// @nodoc
abstract mixin class $SeriesDtoCopyWith<$Res>  {
  factory $SeriesDtoCopyWith(SeriesDto value, $Res Function(SeriesDto) _then) = _$SeriesDtoCopyWithImpl;
@useResult
$Res call({
@HiveField(0) int? id,@HiveField(1) String? name,@HiveField(2) int? volume,@HiveField(3)@JsonKey(name: 'year_began') int? yearBegan,@HiveField(4)@JsonKey(name: 'publisher_name') String? publisherName,@HiveField(5)@JsonKey(name: 'desc') String? description,@HiveField(6)@JsonKey(name: 'series') String? seriesName
});




}
/// @nodoc
class _$SeriesDtoCopyWithImpl<$Res>
    implements $SeriesDtoCopyWith<$Res> {
  _$SeriesDtoCopyWithImpl(this._self, this._then);

  final SeriesDto _self;
  final $Res Function(SeriesDto) _then;

/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? volume = freezed,Object? yearBegan = freezed,Object? publisherName = freezed,Object? description = freezed,Object? seriesName = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int?,yearBegan: freezed == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int?,publisherName: freezed == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SeriesDto].
extension SeriesDtoPatterns on SeriesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeriesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeriesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeriesDto value)  $default,){
final _that = this;
switch (_that) {
case _SeriesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeriesDto value)?  $default,){
final _that = this;
switch (_that) {
case _SeriesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  int? id, @HiveField(1)  String? name, @HiveField(2)  int? volume, @HiveField(3)@JsonKey(name: 'year_began')  int? yearBegan, @HiveField(4)@JsonKey(name: 'publisher_name')  String? publisherName, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'series')  String? seriesName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesDto() when $default != null:
return $default(_that.id,_that.name,_that.volume,_that.yearBegan,_that.publisherName,_that.description,_that.seriesName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  int? id, @HiveField(1)  String? name, @HiveField(2)  int? volume, @HiveField(3)@JsonKey(name: 'year_began')  int? yearBegan, @HiveField(4)@JsonKey(name: 'publisher_name')  String? publisherName, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'series')  String? seriesName)  $default,) {final _that = this;
switch (_that) {
case _SeriesDto():
return $default(_that.id,_that.name,_that.volume,_that.yearBegan,_that.publisherName,_that.description,_that.seriesName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  int? id, @HiveField(1)  String? name, @HiveField(2)  int? volume, @HiveField(3)@JsonKey(name: 'year_began')  int? yearBegan, @HiveField(4)@JsonKey(name: 'publisher_name')  String? publisherName, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'series')  String? seriesName)?  $default,) {final _that = this;
switch (_that) {
case _SeriesDto() when $default != null:
return $default(_that.id,_that.name,_that.volume,_that.yearBegan,_that.publisherName,_that.description,_that.seriesName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeriesDto extends SeriesDto {
  const _SeriesDto({@HiveField(0) this.id, @HiveField(1) this.name, @HiveField(2) this.volume, @HiveField(3)@JsonKey(name: 'year_began') this.yearBegan, @HiveField(4)@JsonKey(name: 'publisher_name') this.publisherName, @HiveField(5)@JsonKey(name: 'desc') this.description, @HiveField(6)@JsonKey(name: 'series') this.seriesName}): super._();
  factory _SeriesDto.fromJson(Map<String, dynamic> json) => _$SeriesDtoFromJson(json);

@override@HiveField(0) final  int? id;
@override@HiveField(1) final  String? name;
@override@HiveField(2) final  int? volume;
@override@HiveField(3)@JsonKey(name: 'year_began') final  int? yearBegan;
@override@HiveField(4)@JsonKey(name: 'publisher_name') final  String? publisherName;
@override@HiveField(5)@JsonKey(name: 'desc') final  String? description;
@override@HiveField(6)@JsonKey(name: 'series') final  String? seriesName;

/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesDtoCopyWith<_SeriesDto> get copyWith => __$SeriesDtoCopyWithImpl<_SeriesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName)&&(identical(other.description, description) || other.description == description)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,volume,yearBegan,publisherName,description,seriesName);

@override
String toString() {
  return 'SeriesDto(id: $id, name: $name, volume: $volume, yearBegan: $yearBegan, publisherName: $publisherName, description: $description, seriesName: $seriesName)';
}


}

/// @nodoc
abstract mixin class _$SeriesDtoCopyWith<$Res> implements $SeriesDtoCopyWith<$Res> {
  factory _$SeriesDtoCopyWith(_SeriesDto value, $Res Function(_SeriesDto) _then) = __$SeriesDtoCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) int? id,@HiveField(1) String? name,@HiveField(2) int? volume,@HiveField(3)@JsonKey(name: 'year_began') int? yearBegan,@HiveField(4)@JsonKey(name: 'publisher_name') String? publisherName,@HiveField(5)@JsonKey(name: 'desc') String? description,@HiveField(6)@JsonKey(name: 'series') String? seriesName
});




}
/// @nodoc
class __$SeriesDtoCopyWithImpl<$Res>
    implements _$SeriesDtoCopyWith<$Res> {
  __$SeriesDtoCopyWithImpl(this._self, this._then);

  final _SeriesDto _self;
  final $Res Function(_SeriesDto) _then;

/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? volume = freezed,Object? yearBegan = freezed,Object? publisherName = freezed,Object? description = freezed,Object? seriesName = freezed,}) {
  return _then(_SeriesDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int?,yearBegan: freezed == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int?,publisherName: freezed == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
