// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Issue {

 int get id; String get name; String get number; String? get seriesName; String? get publisherName; DateTime? get storeDate; DateTime? get coverDate; String? get image; String? get description; bool get isCollected; bool get isRead;
/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueCopyWith<Issue> get copyWith => _$IssueCopyWithImpl<Issue>(this as Issue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Issue&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.number, number) || other.number == number)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.description, description) || other.description == description)&&(identical(other.isCollected, isCollected) || other.isCollected == isCollected)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,number,seriesName,publisherName,storeDate,coverDate,image,description,isCollected,isRead);

@override
String toString() {
  return 'Issue(id: $id, name: $name, number: $number, seriesName: $seriesName, publisherName: $publisherName, storeDate: $storeDate, coverDate: $coverDate, image: $image, description: $description, isCollected: $isCollected, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $IssueCopyWith<$Res>  {
  factory $IssueCopyWith(Issue value, $Res Function(Issue) _then) = _$IssueCopyWithImpl;
@useResult
$Res call({
 int id, String name, String number, String? seriesName, String? publisherName, DateTime? storeDate, DateTime? coverDate, String? image, String? description, bool isCollected, bool isRead
});




}
/// @nodoc
class _$IssueCopyWithImpl<$Res>
    implements $IssueCopyWith<$Res> {
  _$IssueCopyWithImpl(this._self, this._then);

  final Issue _self;
  final $Res Function(Issue) _then;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? number = null,Object? seriesName = freezed,Object? publisherName = freezed,Object? storeDate = freezed,Object? coverDate = freezed,Object? image = freezed,Object? description = freezed,Object? isCollected = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,publisherName: freezed == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as DateTime?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isCollected: null == isCollected ? _self.isCollected : isCollected // ignore: cast_nullable_to_non_nullable
as bool,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Issue].
extension IssuePatterns on Issue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Issue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Issue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Issue value)  $default,){
final _that = this;
switch (_that) {
case _Issue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Issue value)?  $default,){
final _that = this;
switch (_that) {
case _Issue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String number,  String? seriesName,  String? publisherName,  DateTime? storeDate,  DateTime? coverDate,  String? image,  String? description,  bool isCollected,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Issue() when $default != null:
return $default(_that.id,_that.name,_that.number,_that.seriesName,_that.publisherName,_that.storeDate,_that.coverDate,_that.image,_that.description,_that.isCollected,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String number,  String? seriesName,  String? publisherName,  DateTime? storeDate,  DateTime? coverDate,  String? image,  String? description,  bool isCollected,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _Issue():
return $default(_that.id,_that.name,_that.number,_that.seriesName,_that.publisherName,_that.storeDate,_that.coverDate,_that.image,_that.description,_that.isCollected,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String number,  String? seriesName,  String? publisherName,  DateTime? storeDate,  DateTime? coverDate,  String? image,  String? description,  bool isCollected,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _Issue() when $default != null:
return $default(_that.id,_that.name,_that.number,_that.seriesName,_that.publisherName,_that.storeDate,_that.coverDate,_that.image,_that.description,_that.isCollected,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc


class _Issue implements Issue {
  const _Issue({required this.id, required this.name, required this.number, required this.seriesName, required this.publisherName, required this.storeDate, required this.coverDate, required this.image, required this.description, this.isCollected = false, this.isRead = false});
  

@override final  int id;
@override final  String name;
@override final  String number;
@override final  String? seriesName;
@override final  String? publisherName;
@override final  DateTime? storeDate;
@override final  DateTime? coverDate;
@override final  String? image;
@override final  String? description;
@override@JsonKey() final  bool isCollected;
@override@JsonKey() final  bool isRead;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueCopyWith<_Issue> get copyWith => __$IssueCopyWithImpl<_Issue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Issue&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.number, number) || other.number == number)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.description, description) || other.description == description)&&(identical(other.isCollected, isCollected) || other.isCollected == isCollected)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,number,seriesName,publisherName,storeDate,coverDate,image,description,isCollected,isRead);

@override
String toString() {
  return 'Issue(id: $id, name: $name, number: $number, seriesName: $seriesName, publisherName: $publisherName, storeDate: $storeDate, coverDate: $coverDate, image: $image, description: $description, isCollected: $isCollected, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$IssueCopyWith<$Res> implements $IssueCopyWith<$Res> {
  factory _$IssueCopyWith(_Issue value, $Res Function(_Issue) _then) = __$IssueCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String number, String? seriesName, String? publisherName, DateTime? storeDate, DateTime? coverDate, String? image, String? description, bool isCollected, bool isRead
});




}
/// @nodoc
class __$IssueCopyWithImpl<$Res>
    implements _$IssueCopyWith<$Res> {
  __$IssueCopyWithImpl(this._self, this._then);

  final _Issue _self;
  final $Res Function(_Issue) _then;

/// Create a copy of Issue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? number = null,Object? seriesName = freezed,Object? publisherName = freezed,Object? storeDate = freezed,Object? coverDate = freezed,Object? image = freezed,Object? description = freezed,Object? isCollected = null,Object? isRead = null,}) {
  return _then(_Issue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,publisherName: freezed == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as DateTime?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isCollected: null == isCollected ? _self.isCollected : isCollected // ignore: cast_nullable_to_non_nullable
as bool,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
