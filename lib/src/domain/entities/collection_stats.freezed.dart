// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CollectionStats {

 int get totalItems; int get readCount; String get totalValue;
/// Create a copy of CollectionStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionStatsCopyWith<CollectionStats> get copyWith => _$CollectionStatsCopyWithImpl<CollectionStats>(this as CollectionStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionStats&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.readCount, readCount) || other.readCount == readCount)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}


@override
int get hashCode => Object.hash(runtimeType,totalItems,readCount,totalValue);

@override
String toString() {
  return 'CollectionStats(totalItems: $totalItems, readCount: $readCount, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class $CollectionStatsCopyWith<$Res>  {
  factory $CollectionStatsCopyWith(CollectionStats value, $Res Function(CollectionStats) _then) = _$CollectionStatsCopyWithImpl;
@useResult
$Res call({
 int totalItems, int readCount, String totalValue
});




}
/// @nodoc
class _$CollectionStatsCopyWithImpl<$Res>
    implements $CollectionStatsCopyWith<$Res> {
  _$CollectionStatsCopyWithImpl(this._self, this._then);

  final CollectionStats _self;
  final $Res Function(CollectionStats) _then;

/// Create a copy of CollectionStats
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


/// Adds pattern-matching-related methods to [CollectionStats].
extension CollectionStatsPatterns on CollectionStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionStats value)  $default,){
final _that = this;
switch (_that) {
case _CollectionStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionStats value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalItems,  int readCount,  String totalValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionStats() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalItems,  int readCount,  String totalValue)  $default,) {final _that = this;
switch (_that) {
case _CollectionStats():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalItems,  int readCount,  String totalValue)?  $default,) {final _that = this;
switch (_that) {
case _CollectionStats() when $default != null:
return $default(_that.totalItems,_that.readCount,_that.totalValue);case _:
  return null;

}
}

}

/// @nodoc


class _CollectionStats implements CollectionStats {
  const _CollectionStats({required this.totalItems, required this.readCount, required this.totalValue});
  

@override final  int totalItems;
@override final  int readCount;
@override final  String totalValue;

/// Create a copy of CollectionStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionStatsCopyWith<_CollectionStats> get copyWith => __$CollectionStatsCopyWithImpl<_CollectionStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionStats&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.readCount, readCount) || other.readCount == readCount)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue));
}


@override
int get hashCode => Object.hash(runtimeType,totalItems,readCount,totalValue);

@override
String toString() {
  return 'CollectionStats(totalItems: $totalItems, readCount: $readCount, totalValue: $totalValue)';
}


}

/// @nodoc
abstract mixin class _$CollectionStatsCopyWith<$Res> implements $CollectionStatsCopyWith<$Res> {
  factory _$CollectionStatsCopyWith(_CollectionStats value, $Res Function(_CollectionStats) _then) = __$CollectionStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalItems, int readCount, String totalValue
});




}
/// @nodoc
class __$CollectionStatsCopyWithImpl<$Res>
    implements _$CollectionStatsCopyWith<$Res> {
  __$CollectionStatsCopyWithImpl(this._self, this._then);

  final _CollectionStats _self;
  final $Res Function(_CollectionStats) _then;

/// Create a copy of CollectionStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalItems = null,Object? readCount = null,Object? totalValue = null,}) {
  return _then(_CollectionStats(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,readCount: null == readCount ? _self.readCount : readCount // ignore: cast_nullable_to_non_nullable
as int,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
