// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_reading_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalReadingListItem {

 String get targetId; bool get isSeries; ItemRole get role; bool get isRead;
/// Create a copy of LocalReadingListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalReadingListItemCopyWith<LocalReadingListItem> get copyWith => _$LocalReadingListItemCopyWithImpl<LocalReadingListItem>(this as LocalReadingListItem, _$identity);

  /// Serializes this LocalReadingListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalReadingListItem&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.isSeries, isSeries) || other.isSeries == isSeries)&&(identical(other.role, role) || other.role == role)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetId,isSeries,role,isRead);

@override
String toString() {
  return 'LocalReadingListItem(targetId: $targetId, isSeries: $isSeries, role: $role, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $LocalReadingListItemCopyWith<$Res>  {
  factory $LocalReadingListItemCopyWith(LocalReadingListItem value, $Res Function(LocalReadingListItem) _then) = _$LocalReadingListItemCopyWithImpl;
@useResult
$Res call({
 String targetId, bool isSeries, ItemRole role, bool isRead
});




}
/// @nodoc
class _$LocalReadingListItemCopyWithImpl<$Res>
    implements $LocalReadingListItemCopyWith<$Res> {
  _$LocalReadingListItemCopyWithImpl(this._self, this._then);

  final LocalReadingListItem _self;
  final $Res Function(LocalReadingListItem) _then;

/// Create a copy of LocalReadingListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetId = null,Object? isSeries = null,Object? role = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,isSeries: null == isSeries ? _self.isSeries : isSeries // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ItemRole,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalReadingListItem].
extension LocalReadingListItemPatterns on LocalReadingListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalReadingListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalReadingListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalReadingListItem value)  $default,){
final _that = this;
switch (_that) {
case _LocalReadingListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalReadingListItem value)?  $default,){
final _that = this;
switch (_that) {
case _LocalReadingListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String targetId,  bool isSeries,  ItemRole role,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalReadingListItem() when $default != null:
return $default(_that.targetId,_that.isSeries,_that.role,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String targetId,  bool isSeries,  ItemRole role,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _LocalReadingListItem():
return $default(_that.targetId,_that.isSeries,_that.role,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String targetId,  bool isSeries,  ItemRole role,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _LocalReadingListItem() when $default != null:
return $default(_that.targetId,_that.isSeries,_that.role,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalReadingListItem implements LocalReadingListItem {
  const _LocalReadingListItem({required this.targetId, required this.isSeries, required this.role, required this.isRead});
  factory _LocalReadingListItem.fromJson(Map<String, dynamic> json) => _$LocalReadingListItemFromJson(json);

@override final  String targetId;
@override final  bool isSeries;
@override final  ItemRole role;
@override final  bool isRead;

/// Create a copy of LocalReadingListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalReadingListItemCopyWith<_LocalReadingListItem> get copyWith => __$LocalReadingListItemCopyWithImpl<_LocalReadingListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalReadingListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalReadingListItem&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.isSeries, isSeries) || other.isSeries == isSeries)&&(identical(other.role, role) || other.role == role)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,targetId,isSeries,role,isRead);

@override
String toString() {
  return 'LocalReadingListItem(targetId: $targetId, isSeries: $isSeries, role: $role, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$LocalReadingListItemCopyWith<$Res> implements $LocalReadingListItemCopyWith<$Res> {
  factory _$LocalReadingListItemCopyWith(_LocalReadingListItem value, $Res Function(_LocalReadingListItem) _then) = __$LocalReadingListItemCopyWithImpl;
@override @useResult
$Res call({
 String targetId, bool isSeries, ItemRole role, bool isRead
});




}
/// @nodoc
class __$LocalReadingListItemCopyWithImpl<$Res>
    implements _$LocalReadingListItemCopyWith<$Res> {
  __$LocalReadingListItemCopyWithImpl(this._self, this._then);

  final _LocalReadingListItem _self;
  final $Res Function(_LocalReadingListItem) _then;

/// Create a copy of LocalReadingListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetId = null,Object? isSeries = null,Object? role = null,Object? isRead = null,}) {
  return _then(_LocalReadingListItem(
targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,isSeries: null == isSeries ? _self.isSeries : isSeries // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ItemRole,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LocalReadingList {

 String get id; String get title; String get description; bool get isOrdered; ListContentType get contentType; DateTime get createdAt; DateTime get updatedAt; List<LocalReadingListItem> get items; int? get metronSourceId; String? get metronAttributionSource; String? get metronAttributionUrl; String? get metronImageUrl; String? get metronListType; DateTime? get lastSyncedAt;
/// Create a copy of LocalReadingList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalReadingListCopyWith<LocalReadingList> get copyWith => _$LocalReadingListCopyWithImpl<LocalReadingList>(this as LocalReadingList, _$identity);

  /// Serializes this LocalReadingList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalReadingList&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isOrdered, isOrdered) || other.isOrdered == isOrdered)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.metronSourceId, metronSourceId) || other.metronSourceId == metronSourceId)&&(identical(other.metronAttributionSource, metronAttributionSource) || other.metronAttributionSource == metronAttributionSource)&&(identical(other.metronAttributionUrl, metronAttributionUrl) || other.metronAttributionUrl == metronAttributionUrl)&&(identical(other.metronImageUrl, metronImageUrl) || other.metronImageUrl == metronImageUrl)&&(identical(other.metronListType, metronListType) || other.metronListType == metronListType)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,isOrdered,contentType,createdAt,updatedAt,const DeepCollectionEquality().hash(items),metronSourceId,metronAttributionSource,metronAttributionUrl,metronImageUrl,metronListType,lastSyncedAt);

@override
String toString() {
  return 'LocalReadingList(id: $id, title: $title, description: $description, isOrdered: $isOrdered, contentType: $contentType, createdAt: $createdAt, updatedAt: $updatedAt, items: $items, metronSourceId: $metronSourceId, metronAttributionSource: $metronAttributionSource, metronAttributionUrl: $metronAttributionUrl, metronImageUrl: $metronImageUrl, metronListType: $metronListType, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $LocalReadingListCopyWith<$Res>  {
  factory $LocalReadingListCopyWith(LocalReadingList value, $Res Function(LocalReadingList) _then) = _$LocalReadingListCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, bool isOrdered, ListContentType contentType, DateTime createdAt, DateTime updatedAt, List<LocalReadingListItem> items, int? metronSourceId, String? metronAttributionSource, String? metronAttributionUrl, String? metronImageUrl, String? metronListType, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$LocalReadingListCopyWithImpl<$Res>
    implements $LocalReadingListCopyWith<$Res> {
  _$LocalReadingListCopyWithImpl(this._self, this._then);

  final LocalReadingList _self;
  final $Res Function(LocalReadingList) _then;

/// Create a copy of LocalReadingList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? isOrdered = null,Object? contentType = null,Object? createdAt = null,Object? updatedAt = null,Object? items = null,Object? metronSourceId = freezed,Object? metronAttributionSource = freezed,Object? metronAttributionUrl = freezed,Object? metronImageUrl = freezed,Object? metronListType = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isOrdered: null == isOrdered ? _self.isOrdered : isOrdered // ignore: cast_nullable_to_non_nullable
as bool,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as ListContentType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<LocalReadingListItem>,metronSourceId: freezed == metronSourceId ? _self.metronSourceId : metronSourceId // ignore: cast_nullable_to_non_nullable
as int?,metronAttributionSource: freezed == metronAttributionSource ? _self.metronAttributionSource : metronAttributionSource // ignore: cast_nullable_to_non_nullable
as String?,metronAttributionUrl: freezed == metronAttributionUrl ? _self.metronAttributionUrl : metronAttributionUrl // ignore: cast_nullable_to_non_nullable
as String?,metronImageUrl: freezed == metronImageUrl ? _self.metronImageUrl : metronImageUrl // ignore: cast_nullable_to_non_nullable
as String?,metronListType: freezed == metronListType ? _self.metronListType : metronListType // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalReadingList].
extension LocalReadingListPatterns on LocalReadingList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalReadingList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalReadingList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalReadingList value)  $default,){
final _that = this;
switch (_that) {
case _LocalReadingList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalReadingList value)?  $default,){
final _that = this;
switch (_that) {
case _LocalReadingList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  bool isOrdered,  ListContentType contentType,  DateTime createdAt,  DateTime updatedAt,  List<LocalReadingListItem> items,  int? metronSourceId,  String? metronAttributionSource,  String? metronAttributionUrl,  String? metronImageUrl,  String? metronListType,  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalReadingList() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.isOrdered,_that.contentType,_that.createdAt,_that.updatedAt,_that.items,_that.metronSourceId,_that.metronAttributionSource,_that.metronAttributionUrl,_that.metronImageUrl,_that.metronListType,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  bool isOrdered,  ListContentType contentType,  DateTime createdAt,  DateTime updatedAt,  List<LocalReadingListItem> items,  int? metronSourceId,  String? metronAttributionSource,  String? metronAttributionUrl,  String? metronImageUrl,  String? metronListType,  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _LocalReadingList():
return $default(_that.id,_that.title,_that.description,_that.isOrdered,_that.contentType,_that.createdAt,_that.updatedAt,_that.items,_that.metronSourceId,_that.metronAttributionSource,_that.metronAttributionUrl,_that.metronImageUrl,_that.metronListType,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  bool isOrdered,  ListContentType contentType,  DateTime createdAt,  DateTime updatedAt,  List<LocalReadingListItem> items,  int? metronSourceId,  String? metronAttributionSource,  String? metronAttributionUrl,  String? metronImageUrl,  String? metronListType,  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _LocalReadingList() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.isOrdered,_that.contentType,_that.createdAt,_that.updatedAt,_that.items,_that.metronSourceId,_that.metronAttributionSource,_that.metronAttributionUrl,_that.metronImageUrl,_that.metronListType,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalReadingList implements LocalReadingList {
  const _LocalReadingList({required this.id, required this.title, required this.description, required this.isOrdered, required this.contentType, required this.createdAt, required this.updatedAt, required final  List<LocalReadingListItem> items, this.metronSourceId, this.metronAttributionSource, this.metronAttributionUrl, this.metronImageUrl, this.metronListType, this.lastSyncedAt}): _items = items;
  factory _LocalReadingList.fromJson(Map<String, dynamic> json) => _$LocalReadingListFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  bool isOrdered;
@override final  ListContentType contentType;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<LocalReadingListItem> _items;
@override List<LocalReadingListItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int? metronSourceId;
@override final  String? metronAttributionSource;
@override final  String? metronAttributionUrl;
@override final  String? metronImageUrl;
@override final  String? metronListType;
@override final  DateTime? lastSyncedAt;

/// Create a copy of LocalReadingList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalReadingListCopyWith<_LocalReadingList> get copyWith => __$LocalReadingListCopyWithImpl<_LocalReadingList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalReadingListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalReadingList&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isOrdered, isOrdered) || other.isOrdered == isOrdered)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.metronSourceId, metronSourceId) || other.metronSourceId == metronSourceId)&&(identical(other.metronAttributionSource, metronAttributionSource) || other.metronAttributionSource == metronAttributionSource)&&(identical(other.metronAttributionUrl, metronAttributionUrl) || other.metronAttributionUrl == metronAttributionUrl)&&(identical(other.metronImageUrl, metronImageUrl) || other.metronImageUrl == metronImageUrl)&&(identical(other.metronListType, metronListType) || other.metronListType == metronListType)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,isOrdered,contentType,createdAt,updatedAt,const DeepCollectionEquality().hash(_items),metronSourceId,metronAttributionSource,metronAttributionUrl,metronImageUrl,metronListType,lastSyncedAt);

@override
String toString() {
  return 'LocalReadingList(id: $id, title: $title, description: $description, isOrdered: $isOrdered, contentType: $contentType, createdAt: $createdAt, updatedAt: $updatedAt, items: $items, metronSourceId: $metronSourceId, metronAttributionSource: $metronAttributionSource, metronAttributionUrl: $metronAttributionUrl, metronImageUrl: $metronImageUrl, metronListType: $metronListType, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$LocalReadingListCopyWith<$Res> implements $LocalReadingListCopyWith<$Res> {
  factory _$LocalReadingListCopyWith(_LocalReadingList value, $Res Function(_LocalReadingList) _then) = __$LocalReadingListCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, bool isOrdered, ListContentType contentType, DateTime createdAt, DateTime updatedAt, List<LocalReadingListItem> items, int? metronSourceId, String? metronAttributionSource, String? metronAttributionUrl, String? metronImageUrl, String? metronListType, DateTime? lastSyncedAt
});




}
/// @nodoc
class __$LocalReadingListCopyWithImpl<$Res>
    implements _$LocalReadingListCopyWith<$Res> {
  __$LocalReadingListCopyWithImpl(this._self, this._then);

  final _LocalReadingList _self;
  final $Res Function(_LocalReadingList) _then;

/// Create a copy of LocalReadingList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? isOrdered = null,Object? contentType = null,Object? createdAt = null,Object? updatedAt = null,Object? items = null,Object? metronSourceId = freezed,Object? metronAttributionSource = freezed,Object? metronAttributionUrl = freezed,Object? metronImageUrl = freezed,Object? metronListType = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_LocalReadingList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isOrdered: null == isOrdered ? _self.isOrdered : isOrdered // ignore: cast_nullable_to_non_nullable
as bool,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as ListContentType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<LocalReadingListItem>,metronSourceId: freezed == metronSourceId ? _self.metronSourceId : metronSourceId // ignore: cast_nullable_to_non_nullable
as int?,metronAttributionSource: freezed == metronAttributionSource ? _self.metronAttributionSource : metronAttributionSource // ignore: cast_nullable_to_non_nullable
as String?,metronAttributionUrl: freezed == metronAttributionUrl ? _self.metronAttributionUrl : metronAttributionUrl // ignore: cast_nullable_to_non_nullable
as String?,metronImageUrl: freezed == metronImageUrl ? _self.metronImageUrl : metronImageUrl // ignore: cast_nullable_to_non_nullable
as String?,metronListType: freezed == metronListType ? _self.metronListType : metronListType // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
