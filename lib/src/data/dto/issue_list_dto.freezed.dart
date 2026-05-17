// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_list_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IssueListDto {

@HiveField(0) int get id;@HiveField(1) String get number;@HiveField(2) IssueListSeriesDto? get series;@HiveField(3)@JsonKey(name: 'cover_date') String? get coverDate;@HiveField(4)@JsonKey(name: 'store_date') String? get storeDate;@HiveField(5) String? get image;@HiveField(6)@JsonKey(name: 'issue') String? get issueName;@HiveField(7) String? get modified;@HiveField(8)@JsonKey(name: 'cover_hash') String? get coverHash;
/// Create a copy of IssueListDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueListDtoCopyWith<IssueListDto> get copyWith => _$IssueListDtoCopyWithImpl<IssueListDto>(this as IssueListDto, _$identity);

  /// Serializes this IssueListDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueListDto&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.series, series) || other.series == series)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.issueName, issueName) || other.issueName == issueName)&&(identical(other.modified, modified) || other.modified == modified)&&(identical(other.coverHash, coverHash) || other.coverHash == coverHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,series,coverDate,storeDate,image,issueName,modified,coverHash);

@override
String toString() {
  return 'IssueListDto(id: $id, number: $number, series: $series, coverDate: $coverDate, storeDate: $storeDate, image: $image, issueName: $issueName, modified: $modified, coverHash: $coverHash)';
}


}

/// @nodoc
abstract mixin class $IssueListDtoCopyWith<$Res>  {
  factory $IssueListDtoCopyWith(IssueListDto value, $Res Function(IssueListDto) _then) = _$IssueListDtoCopyWithImpl;
@useResult
$Res call({
@HiveField(0) int id,@HiveField(1) String number,@HiveField(2) IssueListSeriesDto? series,@HiveField(3)@JsonKey(name: 'cover_date') String? coverDate,@HiveField(4)@JsonKey(name: 'store_date') String? storeDate,@HiveField(5) String? image,@HiveField(6)@JsonKey(name: 'issue') String? issueName,@HiveField(7) String? modified,@HiveField(8)@JsonKey(name: 'cover_hash') String? coverHash
});


$IssueListSeriesDtoCopyWith<$Res>? get series;

}
/// @nodoc
class _$IssueListDtoCopyWithImpl<$Res>
    implements $IssueListDtoCopyWith<$Res> {
  _$IssueListDtoCopyWithImpl(this._self, this._then);

  final IssueListDto _self;
  final $Res Function(IssueListDto) _then;

/// Create a copy of IssueListDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? series = freezed,Object? coverDate = freezed,Object? storeDate = freezed,Object? image = freezed,Object? issueName = freezed,Object? modified = freezed,Object? coverHash = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as IssueListSeriesDto?,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as String?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,issueName: freezed == issueName ? _self.issueName : issueName // ignore: cast_nullable_to_non_nullable
as String?,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as String?,coverHash: freezed == coverHash ? _self.coverHash : coverHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of IssueListDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueListSeriesDtoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $IssueListSeriesDtoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueListDto].
extension IssueListDtoPatterns on IssueListDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueListDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueListDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueListDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueListDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueListDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueListDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  int id, @HiveField(1)  String number, @HiveField(2)  IssueListSeriesDto? series, @HiveField(3)@JsonKey(name: 'cover_date')  String? coverDate, @HiveField(4)@JsonKey(name: 'store_date')  String? storeDate, @HiveField(5)  String? image, @HiveField(6)@JsonKey(name: 'issue')  String? issueName, @HiveField(7)  String? modified, @HiveField(8)@JsonKey(name: 'cover_hash')  String? coverHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueListDto() when $default != null:
return $default(_that.id,_that.number,_that.series,_that.coverDate,_that.storeDate,_that.image,_that.issueName,_that.modified,_that.coverHash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  int id, @HiveField(1)  String number, @HiveField(2)  IssueListSeriesDto? series, @HiveField(3)@JsonKey(name: 'cover_date')  String? coverDate, @HiveField(4)@JsonKey(name: 'store_date')  String? storeDate, @HiveField(5)  String? image, @HiveField(6)@JsonKey(name: 'issue')  String? issueName, @HiveField(7)  String? modified, @HiveField(8)@JsonKey(name: 'cover_hash')  String? coverHash)  $default,) {final _that = this;
switch (_that) {
case _IssueListDto():
return $default(_that.id,_that.number,_that.series,_that.coverDate,_that.storeDate,_that.image,_that.issueName,_that.modified,_that.coverHash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  int id, @HiveField(1)  String number, @HiveField(2)  IssueListSeriesDto? series, @HiveField(3)@JsonKey(name: 'cover_date')  String? coverDate, @HiveField(4)@JsonKey(name: 'store_date')  String? storeDate, @HiveField(5)  String? image, @HiveField(6)@JsonKey(name: 'issue')  String? issueName, @HiveField(7)  String? modified, @HiveField(8)@JsonKey(name: 'cover_hash')  String? coverHash)?  $default,) {final _that = this;
switch (_that) {
case _IssueListDto() when $default != null:
return $default(_that.id,_that.number,_that.series,_that.coverDate,_that.storeDate,_that.image,_that.issueName,_that.modified,_that.coverHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueListDto extends IssueListDto {
  const _IssueListDto({@HiveField(0) required this.id, @HiveField(1) required this.number, @HiveField(2) required this.series, @HiveField(3)@JsonKey(name: 'cover_date') this.coverDate, @HiveField(4)@JsonKey(name: 'store_date') this.storeDate, @HiveField(5) required this.image, @HiveField(6)@JsonKey(name: 'issue') this.issueName, @HiveField(7) this.modified, @HiveField(8)@JsonKey(name: 'cover_hash') this.coverHash}): super._();
  factory _IssueListDto.fromJson(Map<String, dynamic> json) => _$IssueListDtoFromJson(json);

@override@HiveField(0) final  int id;
@override@HiveField(1) final  String number;
@override@HiveField(2) final  IssueListSeriesDto? series;
@override@HiveField(3)@JsonKey(name: 'cover_date') final  String? coverDate;
@override@HiveField(4)@JsonKey(name: 'store_date') final  String? storeDate;
@override@HiveField(5) final  String? image;
@override@HiveField(6)@JsonKey(name: 'issue') final  String? issueName;
@override@HiveField(7) final  String? modified;
@override@HiveField(8)@JsonKey(name: 'cover_hash') final  String? coverHash;

/// Create a copy of IssueListDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueListDtoCopyWith<_IssueListDto> get copyWith => __$IssueListDtoCopyWithImpl<_IssueListDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueListDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueListDto&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.series, series) || other.series == series)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.issueName, issueName) || other.issueName == issueName)&&(identical(other.modified, modified) || other.modified == modified)&&(identical(other.coverHash, coverHash) || other.coverHash == coverHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,series,coverDate,storeDate,image,issueName,modified,coverHash);

@override
String toString() {
  return 'IssueListDto(id: $id, number: $number, series: $series, coverDate: $coverDate, storeDate: $storeDate, image: $image, issueName: $issueName, modified: $modified, coverHash: $coverHash)';
}


}

/// @nodoc
abstract mixin class _$IssueListDtoCopyWith<$Res> implements $IssueListDtoCopyWith<$Res> {
  factory _$IssueListDtoCopyWith(_IssueListDto value, $Res Function(_IssueListDto) _then) = __$IssueListDtoCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) int id,@HiveField(1) String number,@HiveField(2) IssueListSeriesDto? series,@HiveField(3)@JsonKey(name: 'cover_date') String? coverDate,@HiveField(4)@JsonKey(name: 'store_date') String? storeDate,@HiveField(5) String? image,@HiveField(6)@JsonKey(name: 'issue') String? issueName,@HiveField(7) String? modified,@HiveField(8)@JsonKey(name: 'cover_hash') String? coverHash
});


@override $IssueListSeriesDtoCopyWith<$Res>? get series;

}
/// @nodoc
class __$IssueListDtoCopyWithImpl<$Res>
    implements _$IssueListDtoCopyWith<$Res> {
  __$IssueListDtoCopyWithImpl(this._self, this._then);

  final _IssueListDto _self;
  final $Res Function(_IssueListDto) _then;

/// Create a copy of IssueListDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? series = freezed,Object? coverDate = freezed,Object? storeDate = freezed,Object? image = freezed,Object? issueName = freezed,Object? modified = freezed,Object? coverHash = freezed,}) {
  return _then(_IssueListDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as IssueListSeriesDto?,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as String?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,issueName: freezed == issueName ? _self.issueName : issueName // ignore: cast_nullable_to_non_nullable
as String?,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as String?,coverHash: freezed == coverHash ? _self.coverHash : coverHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of IssueListDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueListSeriesDtoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $IssueListSeriesDtoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}

// dart format on
