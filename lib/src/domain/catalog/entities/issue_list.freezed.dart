// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IssueList {

 int? get id; String get name; String get number; Series? get series; DateTime? get coverDate; DateTime? get storeDate; String? get image; DateTime? get modified;
/// Create a copy of IssueList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueListCopyWith<IssueList> get copyWith => _$IssueListCopyWithImpl<IssueList>(this as IssueList, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueList&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.number, number) || other.number == number)&&(identical(other.series, series) || other.series == series)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,number,series,coverDate,storeDate,image,modified);

@override
String toString() {
  return 'IssueList(id: $id, name: $name, number: $number, series: $series, coverDate: $coverDate, storeDate: $storeDate, image: $image, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $IssueListCopyWith<$Res>  {
  factory $IssueListCopyWith(IssueList value, $Res Function(IssueList) _then) = _$IssueListCopyWithImpl;
@useResult
$Res call({
 int? id, String name, String number, Series? series, DateTime? coverDate, DateTime? storeDate, String? image, DateTime? modified
});


$SeriesCopyWith<$Res>? get series;

}
/// @nodoc
class _$IssueListCopyWithImpl<$Res>
    implements $IssueListCopyWith<$Res> {
  _$IssueListCopyWithImpl(this._self, this._then);

  final IssueList _self;
  final $Res Function(IssueList) _then;

/// Create a copy of IssueList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? number = null,Object? series = freezed,Object? coverDate = freezed,Object? storeDate = freezed,Object? image = freezed,Object? modified = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as Series?,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as DateTime?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of IssueList
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeriesCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $SeriesCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueList].
extension IssueListPatterns on IssueList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueList value)  $default,){
final _that = this;
switch (_that) {
case _IssueList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueList value)?  $default,){
final _that = this;
switch (_that) {
case _IssueList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  String number,  Series? series,  DateTime? coverDate,  DateTime? storeDate,  String? image,  DateTime? modified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueList() when $default != null:
return $default(_that.id,_that.name,_that.number,_that.series,_that.coverDate,_that.storeDate,_that.image,_that.modified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  String number,  Series? series,  DateTime? coverDate,  DateTime? storeDate,  String? image,  DateTime? modified)  $default,) {final _that = this;
switch (_that) {
case _IssueList():
return $default(_that.id,_that.name,_that.number,_that.series,_that.coverDate,_that.storeDate,_that.image,_that.modified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  String number,  Series? series,  DateTime? coverDate,  DateTime? storeDate,  String? image,  DateTime? modified)?  $default,) {final _that = this;
switch (_that) {
case _IssueList() when $default != null:
return $default(_that.id,_that.name,_that.number,_that.series,_that.coverDate,_that.storeDate,_that.image,_that.modified);case _:
  return null;

}
}

}

/// @nodoc


class _IssueList implements IssueList {
  const _IssueList({this.id, required this.name, required this.number, required this.series, required this.coverDate, required this.storeDate, required this.image, required this.modified});
  

@override final  int? id;
@override final  String name;
@override final  String number;
@override final  Series? series;
@override final  DateTime? coverDate;
@override final  DateTime? storeDate;
@override final  String? image;
@override final  DateTime? modified;

/// Create a copy of IssueList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueListCopyWith<_IssueList> get copyWith => __$IssueListCopyWithImpl<_IssueList>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueList&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.number, number) || other.number == number)&&(identical(other.series, series) || other.series == series)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,number,series,coverDate,storeDate,image,modified);

@override
String toString() {
  return 'IssueList(id: $id, name: $name, number: $number, series: $series, coverDate: $coverDate, storeDate: $storeDate, image: $image, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$IssueListCopyWith<$Res> implements $IssueListCopyWith<$Res> {
  factory _$IssueListCopyWith(_IssueList value, $Res Function(_IssueList) _then) = __$IssueListCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, String number, Series? series, DateTime? coverDate, DateTime? storeDate, String? image, DateTime? modified
});


@override $SeriesCopyWith<$Res>? get series;

}
/// @nodoc
class __$IssueListCopyWithImpl<$Res>
    implements _$IssueListCopyWith<$Res> {
  __$IssueListCopyWithImpl(this._self, this._then);

  final _IssueList _self;
  final $Res Function(_IssueList) _then;

/// Create a copy of IssueList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? number = null,Object? series = freezed,Object? coverDate = freezed,Object? storeDate = freezed,Object? image = freezed,Object? modified = freezed,}) {
  return _then(_IssueList(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as Series?,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as DateTime?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of IssueList
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeriesCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $SeriesCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}

// dart format on
