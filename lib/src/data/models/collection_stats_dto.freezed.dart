// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_stats_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CollectionStatsDto {

@HiveField(0)@JsonKey(name: 'total_items') int get totalItems;@HiveField(1)@JsonKey(name: 'read_count') int get readCount;@HiveField(2)@JsonKey(name: 'total_value') String get totalValue;
/// Create a copy of CollectionStatsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionStatsDtoCopyWith<CollectionStatsDto> get copyWith => _$CollectionStatsDtoCopyWithImpl<CollectionStatsDto>(this as CollectionStatsDto, _$identity);

  /// Serializes this CollectionStatsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionStatsDto&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.readCount, readCount) || other.readCount == readCount)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalItems,readCount,totalValue);

@override
String toString() {
  return 'CollectionStatsDto(totalItems: $totalItems, readCount: $readCount, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class $CollectionStatsDtoCopyWith<$Res>  {
  factory $CollectionStatsDtoCopyWith(CollectionStatsDto value, $Res Function(CollectionStatsDto) _then) = _$CollectionStatsDtoCopyWithImpl;
@useResult
$Res call({
@HiveField(0)@JsonKey(name: 'total_items') int totalItems,@HiveField(1)@JsonKey(name: 'read_count') int readCount,@HiveField(2)@JsonKey(name: 'total_value') String totalValue
});




}
/// @nodoc
class _$CollectionStatsDtoCopyWithImpl<$Res>
    implements $CollectionStatsDtoCopyWith<$Res> {
  _$CollectionStatsDtoCopyWithImpl(this._self, this._then);

  final CollectionStatsDto _self;
  final $Res Function(CollectionStatsDto) _then;

/// Create a copy of CollectionStatsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalItems = null,Object? readCount = null,Object? totalValue = null,}) {
  return _then(_self.copyWith(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,readCount: null == readCount ? _self.readCount : readCount // ignore: cast_nullable_to_non_nullable
as int,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionStatsDto].
extension CollectionStatsDtoPatterns on CollectionStatsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionStatsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionStatsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionStatsDto value)  $default,){
final _that = this;
switch (_that) {
case _CollectionStatsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionStatsDto value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionStatsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)@JsonKey(name: 'total_items')  int totalItems, @HiveField(1)@JsonKey(name: 'read_count')  int readCount, @HiveField(2)@JsonKey(name: 'total_value')  String totalValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionStatsDto() when $default != null:
return $default(_that.totalItems,_that.readCount,_that.totalValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)@JsonKey(name: 'total_items')  int totalItems, @HiveField(1)@JsonKey(name: 'read_count')  int readCount, @HiveField(2)@JsonKey(name: 'total_value')  String totalValue)  $default,) {final _that = this;
switch (_that) {
case _CollectionStatsDto():
return $default(_that.totalItems,_that.readCount,_that.totalValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)@JsonKey(name: 'total_items')  int totalItems, @HiveField(1)@JsonKey(name: 'read_count')  int readCount, @HiveField(2)@JsonKey(name: 'total_value')  String totalValue)?  $default,) {final _that = this;
switch (_that) {
case _CollectionStatsDto() when $default != null:
return $default(_that.totalItems,_that.readCount,_that.totalValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionStatsDto extends CollectionStatsDto {
  const _CollectionStatsDto({@HiveField(0)@JsonKey(name: 'total_items') required this.totalItems, @HiveField(1)@JsonKey(name: 'read_count') required this.readCount, @HiveField(2)@JsonKey(name: 'total_value') required this.totalValue}): super._();
  factory _CollectionStatsDto.fromJson(Map<String, dynamic> json) => _$CollectionStatsDtoFromJson(json);

@override@HiveField(0)@JsonKey(name: 'total_items') final  int totalItems;
@override@HiveField(1)@JsonKey(name: 'read_count') final  int readCount;
@override@HiveField(2)@JsonKey(name: 'total_value') final  String totalValue;

/// Create a copy of CollectionStatsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionStatsDtoCopyWith<_CollectionStatsDto> get copyWith => __$CollectionStatsDtoCopyWithImpl<_CollectionStatsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionStatsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionStatsDto&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.readCount, readCount) || other.readCount == readCount)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalItems,readCount,totalValue);

@override
String toString() {
  return 'CollectionStatsDto(totalItems: $totalItems, readCount: $readCount, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class _$CollectionStatsDtoCopyWith<$Res> implements $CollectionStatsDtoCopyWith<$Res> {
  factory _$CollectionStatsDtoCopyWith(_CollectionStatsDto value, $Res Function(_CollectionStatsDto) _then) = __$CollectionStatsDtoCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0)@JsonKey(name: 'total_items') int totalItems,@HiveField(1)@JsonKey(name: 'read_count') int readCount,@HiveField(2)@JsonKey(name: 'total_value') String totalValue
});




}
/// @nodoc
class __$CollectionStatsDtoCopyWithImpl<$Res>
    implements _$CollectionStatsDtoCopyWith<$Res> {
  __$CollectionStatsDtoCopyWithImpl(this._self, this._then);

  final _CollectionStatsDto _self;
  final $Res Function(_CollectionStatsDto) _then;

/// Create a copy of CollectionStatsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalItems = null,Object? readCount = null,Object? totalValue = null,}) {
  return _then(_CollectionStatsDto(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,readCount: null == readCount ? _self.readCount : readCount // ignore: cast_nullable_to_non_nullable
as int,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
