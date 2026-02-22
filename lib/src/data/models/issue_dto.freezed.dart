// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IssueDto {

@HiveField(0) int get id;@HiveField(1) String get number;@HiveField(2) SeriesDto? get series;@HiveField(3)@JsonKey(name: 'store_date') String? get storeDate;@HiveField(4) String? get image;@HiveField(5)@JsonKey(name: 'desc') String? get description;@HiveField(6)@JsonKey(name: 'issue') String? get issueName;
/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDtoCopyWith<IssueDto> get copyWith => _$IssueDtoCopyWithImpl<IssueDto>(this as IssueDto, _$identity);

  /// Serializes this IssueDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDto&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.series, series) || other.series == series)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.description, description) || other.description == description)&&(identical(other.issueName, issueName) || other.issueName == issueName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,series,storeDate,image,description,issueName);

@override
String toString() {
  return 'IssueDto(id: $id, number: $number, series: $series, storeDate: $storeDate, image: $image, description: $description, issueName: $issueName)';
}


}

/// @nodoc
abstract mixin class $IssueDtoCopyWith<$Res>  {
  factory $IssueDtoCopyWith(IssueDto value, $Res Function(IssueDto) _then) = _$IssueDtoCopyWithImpl;
@useResult
$Res call({
@HiveField(0) int id,@HiveField(1) String number,@HiveField(2) SeriesDto? series,@HiveField(3)@JsonKey(name: 'store_date') String? storeDate,@HiveField(4) String? image,@HiveField(5)@JsonKey(name: 'desc') String? description,@HiveField(6)@JsonKey(name: 'issue') String? issueName
});


$SeriesDtoCopyWith<$Res>? get series;

}
/// @nodoc
class _$IssueDtoCopyWithImpl<$Res>
    implements $IssueDtoCopyWith<$Res> {
  _$IssueDtoCopyWithImpl(this._self, this._then);

  final IssueDto _self;
  final $Res Function(IssueDto) _then;

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? series = freezed,Object? storeDate = freezed,Object? image = freezed,Object? description = freezed,Object? issueName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as SeriesDto?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,issueName: freezed == issueName ? _self.issueName : issueName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeriesDtoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $SeriesDtoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueDto].
extension IssueDtoPatterns on IssueDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  int id, @HiveField(1)  String number, @HiveField(2)  SeriesDto? series, @HiveField(3)@JsonKey(name: 'store_date')  String? storeDate, @HiveField(4)  String? image, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'issue')  String? issueName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
return $default(_that.id,_that.number,_that.series,_that.storeDate,_that.image,_that.description,_that.issueName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  int id, @HiveField(1)  String number, @HiveField(2)  SeriesDto? series, @HiveField(3)@JsonKey(name: 'store_date')  String? storeDate, @HiveField(4)  String? image, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'issue')  String? issueName)  $default,) {final _that = this;
switch (_that) {
case _IssueDto():
return $default(_that.id,_that.number,_that.series,_that.storeDate,_that.image,_that.description,_that.issueName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  int id, @HiveField(1)  String number, @HiveField(2)  SeriesDto? series, @HiveField(3)@JsonKey(name: 'store_date')  String? storeDate, @HiveField(4)  String? image, @HiveField(5)@JsonKey(name: 'desc')  String? description, @HiveField(6)@JsonKey(name: 'issue')  String? issueName)?  $default,) {final _that = this;
switch (_that) {
case _IssueDto() when $default != null:
return $default(_that.id,_that.number,_that.series,_that.storeDate,_that.image,_that.description,_that.issueName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDto extends IssueDto {
  const _IssueDto({@HiveField(0) required this.id, @HiveField(1) required this.number, @HiveField(2) required this.series, @HiveField(3)@JsonKey(name: 'store_date') required this.storeDate, @HiveField(4) required this.image, @HiveField(5)@JsonKey(name: 'desc') this.description, @HiveField(6)@JsonKey(name: 'issue') required this.issueName}): super._();
  factory _IssueDto.fromJson(Map<String, dynamic> json) => _$IssueDtoFromJson(json);

@override@HiveField(0) final  int id;
@override@HiveField(1) final  String number;
@override@HiveField(2) final  SeriesDto? series;
@override@HiveField(3)@JsonKey(name: 'store_date') final  String? storeDate;
@override@HiveField(4) final  String? image;
@override@HiveField(5)@JsonKey(name: 'desc') final  String? description;
@override@HiveField(6)@JsonKey(name: 'issue') final  String? issueName;

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDtoCopyWith<_IssueDto> get copyWith => __$IssueDtoCopyWithImpl<_IssueDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDto&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.series, series) || other.series == series)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.description, description) || other.description == description)&&(identical(other.issueName, issueName) || other.issueName == issueName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,series,storeDate,image,description,issueName);

@override
String toString() {
  return 'IssueDto(id: $id, number: $number, series: $series, storeDate: $storeDate, image: $image, description: $description, issueName: $issueName)';
}


}

/// @nodoc
abstract mixin class _$IssueDtoCopyWith<$Res> implements $IssueDtoCopyWith<$Res> {
  factory _$IssueDtoCopyWith(_IssueDto value, $Res Function(_IssueDto) _then) = __$IssueDtoCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) int id,@HiveField(1) String number,@HiveField(2) SeriesDto? series,@HiveField(3)@JsonKey(name: 'store_date') String? storeDate,@HiveField(4) String? image,@HiveField(5)@JsonKey(name: 'desc') String? description,@HiveField(6)@JsonKey(name: 'issue') String? issueName
});


@override $SeriesDtoCopyWith<$Res>? get series;

}
/// @nodoc
class __$IssueDtoCopyWithImpl<$Res>
    implements _$IssueDtoCopyWith<$Res> {
  __$IssueDtoCopyWithImpl(this._self, this._then);

  final _IssueDto _self;
  final $Res Function(_IssueDto) _then;

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? series = freezed,Object? storeDate = freezed,Object? image = freezed,Object? description = freezed,Object? issueName = freezed,}) {
  return _then(_IssueDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as SeriesDto?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,issueName: freezed == issueName ? _self.issueName : issueName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of IssueDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeriesDtoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $SeriesDtoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}

// dart format on
