// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_results_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchResultsState {

 String get query; SearchType get searchType; List<dynamic> get results; int get totalCount; bool get isLoading; String? get errorMessage;
/// Create a copy of SearchResultsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultsStateCopyWith<SearchResultsState> get copyWith => _$SearchResultsStateCopyWithImpl<SearchResultsState>(this as SearchResultsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResultsState&&(identical(other.query, query) || other.query == query)&&(identical(other.searchType, searchType) || other.searchType == searchType)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,query,searchType,const DeepCollectionEquality().hash(results),totalCount,isLoading,errorMessage);

@override
String toString() {
  return 'SearchResultsState(query: $query, searchType: $searchType, results: $results, totalCount: $totalCount, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SearchResultsStateCopyWith<$Res>  {
  factory $SearchResultsStateCopyWith(SearchResultsState value, $Res Function(SearchResultsState) _then) = _$SearchResultsStateCopyWithImpl;
@useResult
$Res call({
 String query, SearchType searchType, List<dynamic> results, int totalCount, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$SearchResultsStateCopyWithImpl<$Res>
    implements $SearchResultsStateCopyWith<$Res> {
  _$SearchResultsStateCopyWithImpl(this._self, this._then);

  final SearchResultsState _self;
  final $Res Function(SearchResultsState) _then;

/// Create a copy of SearchResultsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? searchType = null,Object? results = null,Object? totalCount = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,searchType: null == searchType ? _self.searchType : searchType // ignore: cast_nullable_to_non_nullable
as SearchType,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<dynamic>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResultsState].
extension SearchResultsStatePatterns on SearchResultsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResultsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResultsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResultsState value)  $default,){
final _that = this;
switch (_that) {
case _SearchResultsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResultsState value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResultsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  SearchType searchType,  List<dynamic> results,  int totalCount,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResultsState() when $default != null:
return $default(_that.query,_that.searchType,_that.results,_that.totalCount,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  SearchType searchType,  List<dynamic> results,  int totalCount,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SearchResultsState():
return $default(_that.query,_that.searchType,_that.results,_that.totalCount,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  SearchType searchType,  List<dynamic> results,  int totalCount,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SearchResultsState() when $default != null:
return $default(_that.query,_that.searchType,_that.results,_that.totalCount,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SearchResultsState implements SearchResultsState {
  const _SearchResultsState({this.query = '', this.searchType = SearchType.series, final  List<dynamic> results = const [], this.totalCount = 0, this.isLoading = false, this.errorMessage}): _results = results;
  

@override@JsonKey() final  String query;
@override@JsonKey() final  SearchType searchType;
 final  List<dynamic> _results;
@override@JsonKey() List<dynamic> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  int totalCount;
@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of SearchResultsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultsStateCopyWith<_SearchResultsState> get copyWith => __$SearchResultsStateCopyWithImpl<_SearchResultsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResultsState&&(identical(other.query, query) || other.query == query)&&(identical(other.searchType, searchType) || other.searchType == searchType)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,query,searchType,const DeepCollectionEquality().hash(_results),totalCount,isLoading,errorMessage);

@override
String toString() {
  return 'SearchResultsState(query: $query, searchType: $searchType, results: $results, totalCount: $totalCount, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SearchResultsStateCopyWith<$Res> implements $SearchResultsStateCopyWith<$Res> {
  factory _$SearchResultsStateCopyWith(_SearchResultsState value, $Res Function(_SearchResultsState) _then) = __$SearchResultsStateCopyWithImpl;
@override @useResult
$Res call({
 String query, SearchType searchType, List<dynamic> results, int totalCount, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$SearchResultsStateCopyWithImpl<$Res>
    implements _$SearchResultsStateCopyWith<$Res> {
  __$SearchResultsStateCopyWithImpl(this._self, this._then);

  final _SearchResultsState _self;
  final $Res Function(_SearchResultsState) _then;

/// Create a copy of SearchResultsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? searchType = null,Object? results = null,Object? totalCount = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_SearchResultsState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,searchType: null == searchType ? _self.searchType : searchType // ignore: cast_nullable_to_non_nullable
as SearchType,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<dynamic>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
