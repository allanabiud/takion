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
mixin _$PublisherDto {

@HiveField(0) int? get id;@HiveField(1) String? get name;
/// Create a copy of PublisherDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublisherDtoCopyWith<PublisherDto> get copyWith => _$PublisherDtoCopyWithImpl<PublisherDto>(this as PublisherDto, _$identity);

  /// Serializes this PublisherDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublisherDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'PublisherDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $PublisherDtoCopyWith<$Res>  {
  factory $PublisherDtoCopyWith(PublisherDto value, $Res Function(PublisherDto) _then) = _$PublisherDtoCopyWithImpl;
@useResult
$Res call({
@HiveField(0) int? id,@HiveField(1) String? name
});




}
/// @nodoc
class _$PublisherDtoCopyWithImpl<$Res>
    implements $PublisherDtoCopyWith<$Res> {
  _$PublisherDtoCopyWithImpl(this._self, this._then);

  final PublisherDto _self;
  final $Res Function(PublisherDto) _then;

/// Create a copy of PublisherDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublisherDto].
extension PublisherDtoPatterns on PublisherDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublisherDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublisherDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublisherDto value)  $default,){
final _that = this;
switch (_that) {
case _PublisherDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublisherDto value)?  $default,){
final _that = this;
switch (_that) {
case _PublisherDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  int? id, @HiveField(1)  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublisherDto() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  int? id, @HiveField(1)  String? name)  $default,) {final _that = this;
switch (_that) {
case _PublisherDto():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  int? id, @HiveField(1)  String? name)?  $default,) {final _that = this;
switch (_that) {
case _PublisherDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublisherDto implements PublisherDto {
  const _PublisherDto({@HiveField(0) this.id, @HiveField(1) this.name});
  factory _PublisherDto.fromJson(Map<String, dynamic> json) => _$PublisherDtoFromJson(json);

@override@HiveField(0) final  int? id;
@override@HiveField(1) final  String? name;

/// Create a copy of PublisherDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublisherDtoCopyWith<_PublisherDto> get copyWith => __$PublisherDtoCopyWithImpl<_PublisherDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublisherDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublisherDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'PublisherDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$PublisherDtoCopyWith<$Res> implements $PublisherDtoCopyWith<$Res> {
  factory _$PublisherDtoCopyWith(_PublisherDto value, $Res Function(_PublisherDto) _then) = __$PublisherDtoCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) int? id,@HiveField(1) String? name
});




}
/// @nodoc
class __$PublisherDtoCopyWithImpl<$Res>
    implements _$PublisherDtoCopyWith<$Res> {
  __$PublisherDtoCopyWithImpl(this._self, this._then);

  final _PublisherDto _self;
  final $Res Function(_PublisherDto) _then;

/// Create a copy of PublisherDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_PublisherDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SeriesDto {

@HiveField(0) int? get id;@HiveField(1) String? get name;// Used by /api/issue/ nested series
@HiveField(2) int? get volume;@HiveField(3)@JsonKey(name: 'year_began') int? get yearBegan;@HiveField(4)@JsonKey(name: 'publisher_name') String? get publisherName;@HiveField(5)@JsonKey(name: 'desc') String? get description;@HiveField(6)@JsonKey(name: 'year_end') int? get yearEnd;@HiveField(7)@JsonKey(name: 'issue_count') int? get issueCount;@HiveField(8)@JsonKey(name: 'series') String? get seriesName;// Used by /api/series/ list
@HiveField(9) PublisherDto? get publisher;// Used by /api/series/ detail and list
@HiveField(10)@JsonKey(name: 'series_type') SeriesTypeDto? get seriesType;@HiveField(11) String? get status;
/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesDtoCopyWith<SeriesDto> get copyWith => _$SeriesDtoCopyWithImpl<SeriesDto>(this as SeriesDto, _$identity);

  /// Serializes this SeriesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName)&&(identical(other.description, description) || other.description == description)&&(identical(other.yearEnd, yearEnd) || other.yearEnd == yearEnd)&&(identical(other.issueCount, issueCount) || other.issueCount == issueCount)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.seriesType, seriesType) || other.seriesType == seriesType)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,volume,yearBegan,publisherName,description,yearEnd,issueCount,seriesName,publisher,seriesType,status);

@override
String toString() {
  return 'SeriesDto(id: $id, name: $name, volume: $volume, yearBegan: $yearBegan, publisherName: $publisherName, description: $description, yearEnd: $yearEnd, issueCount: $issueCount, seriesName: $seriesName, publisher: $publisher, seriesType: $seriesType, status: $status)';
}


}

/// @nodoc
abstract mixin class $SeriesDtoCopyWith<$Res>  {
  factory $SeriesDtoCopyWith(SeriesDto value, $Res Function(SeriesDto) _then) = _$SeriesDtoCopyWithImpl;
@useResult
$Res call({
@HiveField(0) int? id,@HiveField(1) String? name,@HiveField(2) int? volume,@HiveField(3)@JsonKey(name: 'year_began') int? yearBegan,@HiveField(4)@JsonKey(name: 'publisher_name') String? publisherName,@HiveField(5)@JsonKey(name: 'desc') String? description,@HiveField(6)@JsonKey(name: 'year_end') int? yearEnd,@HiveField(7)@JsonKey(name: 'issue_count') int? issueCount,@HiveField(8)@JsonKey(name: 'series') String? seriesName,@HiveField(9) PublisherDto? publisher,@HiveField(10)@JsonKey(name: 'series_type') SeriesTypeDto? seriesType,@HiveField(11) String? status
});


$PublisherDtoCopyWith<$Res>? get publisher;$SeriesTypeDtoCopyWith<$Res>? get seriesType;

}
/// @nodoc
class _$SeriesDtoCopyWithImpl<$Res>
    implements $SeriesDtoCopyWith<$Res> {
  _$SeriesDtoCopyWithImpl(this._self, this._then);

  final SeriesDto _self;
  final $Res Function(SeriesDto) _then;

/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? volume = freezed,Object? yearBegan = freezed,Object? publisherName = freezed,Object? description = freezed,Object? yearEnd = freezed,Object? issueCount = freezed,Object? seriesName = freezed,Object? publisher = freezed,Object? seriesType = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int?,yearBegan: freezed == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int?,publisherName: freezed == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,yearEnd: freezed == yearEnd ? _self.yearEnd : yearEnd // ignore: cast_nullable_to_non_nullable
as int?,issueCount: freezed == issueCount ? _self.issueCount : issueCount // ignore: cast_nullable_to_non_nullable
as int?,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as PublisherDto?,seriesType: freezed == seriesType ? _self.seriesType : seriesType // ignore: cast_nullable_to_non_nullable
as SeriesTypeDto?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublisherDtoCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $PublisherDtoCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeriesTypeDtoCopyWith<$Res>? get seriesType {
    if (_self.seriesType == null) {
    return null;
  }

  return $SeriesTypeDtoCopyWith<$Res>(_self.seriesType!, (value) {
    return _then(_self.copyWith(seriesType: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  int? id, @HiveField(1)  String? name, @HiveField(2)  int? volume, @HiveField(3)@JsonKey(name: 'year_began')  int? yearBegan, @HiveField(4)@JsonKey(name: 'publisher_name')  String? publisherName, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'year_end')  int? yearEnd, @HiveField(7)@JsonKey(name: 'issue_count')  int? issueCount, @HiveField(8)@JsonKey(name: 'series')  String? seriesName, @HiveField(9)  PublisherDto? publisher, @HiveField(10)@JsonKey(name: 'series_type')  SeriesTypeDto? seriesType, @HiveField(11)  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesDto() when $default != null:
return $default(_that.id,_that.name,_that.volume,_that.yearBegan,_that.publisherName,_that.description,_that.yearEnd,_that.issueCount,_that.seriesName,_that.publisher,_that.seriesType,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  int? id, @HiveField(1)  String? name, @HiveField(2)  int? volume, @HiveField(3)@JsonKey(name: 'year_began')  int? yearBegan, @HiveField(4)@JsonKey(name: 'publisher_name')  String? publisherName, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'year_end')  int? yearEnd, @HiveField(7)@JsonKey(name: 'issue_count')  int? issueCount, @HiveField(8)@JsonKey(name: 'series')  String? seriesName, @HiveField(9)  PublisherDto? publisher, @HiveField(10)@JsonKey(name: 'series_type')  SeriesTypeDto? seriesType, @HiveField(11)  String? status)  $default,) {final _that = this;
switch (_that) {
case _SeriesDto():
return $default(_that.id,_that.name,_that.volume,_that.yearBegan,_that.publisherName,_that.description,_that.yearEnd,_that.issueCount,_that.seriesName,_that.publisher,_that.seriesType,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  int? id, @HiveField(1)  String? name, @HiveField(2)  int? volume, @HiveField(3)@JsonKey(name: 'year_began')  int? yearBegan, @HiveField(4)@JsonKey(name: 'publisher_name')  String? publisherName, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'year_end')  int? yearEnd, @HiveField(7)@JsonKey(name: 'issue_count')  int? issueCount, @HiveField(8)@JsonKey(name: 'series')  String? seriesName, @HiveField(9)  PublisherDto? publisher, @HiveField(10)@JsonKey(name: 'series_type')  SeriesTypeDto? seriesType, @HiveField(11)  String? status)?  $default,) {final _that = this;
switch (_that) {
case _SeriesDto() when $default != null:
return $default(_that.id,_that.name,_that.volume,_that.yearBegan,_that.publisherName,_that.description,_that.yearEnd,_that.issueCount,_that.seriesName,_that.publisher,_that.seriesType,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeriesDto extends SeriesDto {
  const _SeriesDto({@HiveField(0) this.id, @HiveField(1) this.name, @HiveField(2) this.volume, @HiveField(3)@JsonKey(name: 'year_began') this.yearBegan, @HiveField(4)@JsonKey(name: 'publisher_name') this.publisherName, @HiveField(5)@JsonKey(name: 'desc') this.description, @HiveField(6)@JsonKey(name: 'year_end') this.yearEnd, @HiveField(7)@JsonKey(name: 'issue_count') this.issueCount, @HiveField(8)@JsonKey(name: 'series') this.seriesName, @HiveField(9) this.publisher, @HiveField(10)@JsonKey(name: 'series_type') this.seriesType, @HiveField(11) this.status}): super._();
  factory _SeriesDto.fromJson(Map<String, dynamic> json) => _$SeriesDtoFromJson(json);

@override@HiveField(0) final  int? id;
@override@HiveField(1) final  String? name;
// Used by /api/issue/ nested series
@override@HiveField(2) final  int? volume;
@override@HiveField(3)@JsonKey(name: 'year_began') final  int? yearBegan;
@override@HiveField(4)@JsonKey(name: 'publisher_name') final  String? publisherName;
@override@HiveField(5)@JsonKey(name: 'desc') final  String? description;
@override@HiveField(6)@JsonKey(name: 'year_end') final  int? yearEnd;
@override@HiveField(7)@JsonKey(name: 'issue_count') final  int? issueCount;
@override@HiveField(8)@JsonKey(name: 'series') final  String? seriesName;
// Used by /api/series/ list
@override@HiveField(9) final  PublisherDto? publisher;
// Used by /api/series/ detail and list
@override@HiveField(10)@JsonKey(name: 'series_type') final  SeriesTypeDto? seriesType;
@override@HiveField(11) final  String? status;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName)&&(identical(other.description, description) || other.description == description)&&(identical(other.yearEnd, yearEnd) || other.yearEnd == yearEnd)&&(identical(other.issueCount, issueCount) || other.issueCount == issueCount)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.seriesType, seriesType) || other.seriesType == seriesType)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,volume,yearBegan,publisherName,description,yearEnd,issueCount,seriesName,publisher,seriesType,status);

@override
String toString() {
  return 'SeriesDto(id: $id, name: $name, volume: $volume, yearBegan: $yearBegan, publisherName: $publisherName, description: $description, yearEnd: $yearEnd, issueCount: $issueCount, seriesName: $seriesName, publisher: $publisher, seriesType: $seriesType, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SeriesDtoCopyWith<$Res> implements $SeriesDtoCopyWith<$Res> {
  factory _$SeriesDtoCopyWith(_SeriesDto value, $Res Function(_SeriesDto) _then) = __$SeriesDtoCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) int? id,@HiveField(1) String? name,@HiveField(2) int? volume,@HiveField(3)@JsonKey(name: 'year_began') int? yearBegan,@HiveField(4)@JsonKey(name: 'publisher_name') String? publisherName,@HiveField(5)@JsonKey(name: 'desc') String? description,@HiveField(6)@JsonKey(name: 'year_end') int? yearEnd,@HiveField(7)@JsonKey(name: 'issue_count') int? issueCount,@HiveField(8)@JsonKey(name: 'series') String? seriesName,@HiveField(9) PublisherDto? publisher,@HiveField(10)@JsonKey(name: 'series_type') SeriesTypeDto? seriesType,@HiveField(11) String? status
});


@override $PublisherDtoCopyWith<$Res>? get publisher;@override $SeriesTypeDtoCopyWith<$Res>? get seriesType;

}
/// @nodoc
class __$SeriesDtoCopyWithImpl<$Res>
    implements _$SeriesDtoCopyWith<$Res> {
  __$SeriesDtoCopyWithImpl(this._self, this._then);

  final _SeriesDto _self;
  final $Res Function(_SeriesDto) _then;

/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? volume = freezed,Object? yearBegan = freezed,Object? publisherName = freezed,Object? description = freezed,Object? yearEnd = freezed,Object? issueCount = freezed,Object? seriesName = freezed,Object? publisher = freezed,Object? seriesType = freezed,Object? status = freezed,}) {
  return _then(_SeriesDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int?,yearBegan: freezed == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int?,publisherName: freezed == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,yearEnd: freezed == yearEnd ? _self.yearEnd : yearEnd // ignore: cast_nullable_to_non_nullable
as int?,issueCount: freezed == issueCount ? _self.issueCount : issueCount // ignore: cast_nullable_to_non_nullable
as int?,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as PublisherDto?,seriesType: freezed == seriesType ? _self.seriesType : seriesType // ignore: cast_nullable_to_non_nullable
as SeriesTypeDto?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublisherDtoCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $PublisherDtoCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SeriesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeriesTypeDtoCopyWith<$Res>? get seriesType {
    if (_self.seriesType == null) {
    return null;
  }

  return $SeriesTypeDtoCopyWith<$Res>(_self.seriesType!, (value) {
    return _then(_self.copyWith(seriesType: value));
  });
}
}

// dart format on
