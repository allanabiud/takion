// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IssueDetails {

 int get id; IssueDetailsNamedRef? get publisher; IssueDetailsNamedRef? get imprint; IssueDetailsSeries? get series; String get number; String? get altNumber; String? get title; List<String> get names; DateTime? get coverDate; DateTime? get storeDate; DateTime? get focDate; String? get price; String? get priceCurrency; IssueDetailsNamedRef? get rating; String? get sku; String? get isbn; String? get upc; int? get page; String? get description; String? get image; String? get coverHash; List<IssueDetailsParticipation> get arcs; List<IssueDetailsCredit> get credits; List<IssueDetailsParticipation> get characters; List<IssueDetailsParticipation> get teams; List<IssueDetailsParticipation> get universes; List<IssueDetailsReprint> get reprints; List<IssueDetailsVariant> get variants; int? get cvId; int? get gcdId; String? get resourceUrl; DateTime? get modified;
/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsCopyWith<IssueDetails> get copyWith => _$IssueDetailsCopyWithImpl<IssueDetails>(this as IssueDetails, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.imprint, imprint) || other.imprint == imprint)&&(identical(other.series, series) || other.series == series)&&(identical(other.number, number) || other.number == number)&&(identical(other.altNumber, altNumber) || other.altNumber == altNumber)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.names, names)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.focDate, focDate) || other.focDate == focDate)&&(identical(other.price, price) || other.price == price)&&(identical(other.priceCurrency, priceCurrency) || other.priceCurrency == priceCurrency)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.upc, upc) || other.upc == upc)&&(identical(other.page, page) || other.page == page)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.coverHash, coverHash) || other.coverHash == coverHash)&&const DeepCollectionEquality().equals(other.arcs, arcs)&&const DeepCollectionEquality().equals(other.credits, credits)&&const DeepCollectionEquality().equals(other.characters, characters)&&const DeepCollectionEquality().equals(other.teams, teams)&&const DeepCollectionEquality().equals(other.universes, universes)&&const DeepCollectionEquality().equals(other.reprints, reprints)&&const DeepCollectionEquality().equals(other.variants, variants)&&(identical(other.cvId, cvId) || other.cvId == cvId)&&(identical(other.gcdId, gcdId) || other.gcdId == gcdId)&&(identical(other.resourceUrl, resourceUrl) || other.resourceUrl == resourceUrl)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,publisher,imprint,series,number,altNumber,title,const DeepCollectionEquality().hash(names),coverDate,storeDate,focDate,price,priceCurrency,rating,sku,isbn,upc,page,description,image,coverHash,const DeepCollectionEquality().hash(arcs),const DeepCollectionEquality().hash(credits),const DeepCollectionEquality().hash(characters),const DeepCollectionEquality().hash(teams),const DeepCollectionEquality().hash(universes),const DeepCollectionEquality().hash(reprints),const DeepCollectionEquality().hash(variants),cvId,gcdId,resourceUrl,modified]);

@override
String toString() {
  return 'IssueDetails(id: $id, publisher: $publisher, imprint: $imprint, series: $series, number: $number, altNumber: $altNumber, title: $title, names: $names, coverDate: $coverDate, storeDate: $storeDate, focDate: $focDate, price: $price, priceCurrency: $priceCurrency, rating: $rating, sku: $sku, isbn: $isbn, upc: $upc, page: $page, description: $description, image: $image, coverHash: $coverHash, arcs: $arcs, credits: $credits, characters: $characters, teams: $teams, universes: $universes, reprints: $reprints, variants: $variants, cvId: $cvId, gcdId: $gcdId, resourceUrl: $resourceUrl, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsCopyWith<$Res>  {
  factory $IssueDetailsCopyWith(IssueDetails value, $Res Function(IssueDetails) _then) = _$IssueDetailsCopyWithImpl;
@useResult
$Res call({
 int id, IssueDetailsNamedRef? publisher, IssueDetailsNamedRef? imprint, IssueDetailsSeries? series, String number, String? altNumber, String? title, List<String> names, DateTime? coverDate, DateTime? storeDate, DateTime? focDate, String? price, String? priceCurrency, IssueDetailsNamedRef? rating, String? sku, String? isbn, String? upc, int? page, String? description, String? image, String? coverHash, List<IssueDetailsParticipation> arcs, List<IssueDetailsCredit> credits, List<IssueDetailsParticipation> characters, List<IssueDetailsParticipation> teams, List<IssueDetailsParticipation> universes, List<IssueDetailsReprint> reprints, List<IssueDetailsVariant> variants, int? cvId, int? gcdId, String? resourceUrl, DateTime? modified
});


$IssueDetailsNamedRefCopyWith<$Res>? get publisher;$IssueDetailsNamedRefCopyWith<$Res>? get imprint;$IssueDetailsSeriesCopyWith<$Res>? get series;$IssueDetailsNamedRefCopyWith<$Res>? get rating;

}
/// @nodoc
class _$IssueDetailsCopyWithImpl<$Res>
    implements $IssueDetailsCopyWith<$Res> {
  _$IssueDetailsCopyWithImpl(this._self, this._then);

  final IssueDetails _self;
  final $Res Function(IssueDetails) _then;

/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publisher = freezed,Object? imprint = freezed,Object? series = freezed,Object? number = null,Object? altNumber = freezed,Object? title = freezed,Object? names = null,Object? coverDate = freezed,Object? storeDate = freezed,Object? focDate = freezed,Object? price = freezed,Object? priceCurrency = freezed,Object? rating = freezed,Object? sku = freezed,Object? isbn = freezed,Object? upc = freezed,Object? page = freezed,Object? description = freezed,Object? image = freezed,Object? coverHash = freezed,Object? arcs = null,Object? credits = null,Object? characters = null,Object? teams = null,Object? universes = null,Object? reprints = null,Object? variants = null,Object? cvId = freezed,Object? gcdId = freezed,Object? resourceUrl = freezed,Object? modified = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRef?,imprint: freezed == imprint ? _self.imprint : imprint // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRef?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as IssueDetailsSeries?,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,altNumber: freezed == altNumber ? _self.altNumber : altNumber // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as List<String>,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as DateTime?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,focDate: freezed == focDate ? _self.focDate : focDate // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,priceCurrency: freezed == priceCurrency ? _self.priceCurrency : priceCurrency // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRef?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,upc: freezed == upc ? _self.upc : upc // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,coverHash: freezed == coverHash ? _self.coverHash : coverHash // ignore: cast_nullable_to_non_nullable
as String?,arcs: null == arcs ? _self.arcs : arcs // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipation>,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsCredit>,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipation>,teams: null == teams ? _self.teams : teams // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipation>,universes: null == universes ? _self.universes : universes // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipation>,reprints: null == reprints ? _self.reprints : reprints // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsReprint>,variants: null == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsVariant>,cvId: freezed == cvId ? _self.cvId : cvId // ignore: cast_nullable_to_non_nullable
as int?,gcdId: freezed == gcdId ? _self.gcdId : gcdId // ignore: cast_nullable_to_non_nullable
as int?,resourceUrl: freezed == resourceUrl ? _self.resourceUrl : resourceUrl // ignore: cast_nullable_to_non_nullable
as String?,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $IssueDetailsNamedRefCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<$Res>? get imprint {
    if (_self.imprint == null) {
    return null;
  }

  return $IssueDetailsNamedRefCopyWith<$Res>(_self.imprint!, (value) {
    return _then(_self.copyWith(imprint: value));
  });
}/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsSeriesCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $IssueDetailsSeriesCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $IssueDetailsNamedRefCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueDetails].
extension IssueDetailsPatterns on IssueDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetails value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetails value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  IssueDetailsNamedRef? publisher,  IssueDetailsNamedRef? imprint,  IssueDetailsSeries? series,  String number,  String? altNumber,  String? title,  List<String> names,  DateTime? coverDate,  DateTime? storeDate,  DateTime? focDate,  String? price,  String? priceCurrency,  IssueDetailsNamedRef? rating,  String? sku,  String? isbn,  String? upc,  int? page,  String? description,  String? image,  String? coverHash,  List<IssueDetailsParticipation> arcs,  List<IssueDetailsCredit> credits,  List<IssueDetailsParticipation> characters,  List<IssueDetailsParticipation> teams,  List<IssueDetailsParticipation> universes,  List<IssueDetailsReprint> reprints,  List<IssueDetailsVariant> variants,  int? cvId,  int? gcdId,  String? resourceUrl,  DateTime? modified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetails() when $default != null:
return $default(_that.id,_that.publisher,_that.imprint,_that.series,_that.number,_that.altNumber,_that.title,_that.names,_that.coverDate,_that.storeDate,_that.focDate,_that.price,_that.priceCurrency,_that.rating,_that.sku,_that.isbn,_that.upc,_that.page,_that.description,_that.image,_that.coverHash,_that.arcs,_that.credits,_that.characters,_that.teams,_that.universes,_that.reprints,_that.variants,_that.cvId,_that.gcdId,_that.resourceUrl,_that.modified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  IssueDetailsNamedRef? publisher,  IssueDetailsNamedRef? imprint,  IssueDetailsSeries? series,  String number,  String? altNumber,  String? title,  List<String> names,  DateTime? coverDate,  DateTime? storeDate,  DateTime? focDate,  String? price,  String? priceCurrency,  IssueDetailsNamedRef? rating,  String? sku,  String? isbn,  String? upc,  int? page,  String? description,  String? image,  String? coverHash,  List<IssueDetailsParticipation> arcs,  List<IssueDetailsCredit> credits,  List<IssueDetailsParticipation> characters,  List<IssueDetailsParticipation> teams,  List<IssueDetailsParticipation> universes,  List<IssueDetailsReprint> reprints,  List<IssueDetailsVariant> variants,  int? cvId,  int? gcdId,  String? resourceUrl,  DateTime? modified)  $default,) {final _that = this;
switch (_that) {
case _IssueDetails():
return $default(_that.id,_that.publisher,_that.imprint,_that.series,_that.number,_that.altNumber,_that.title,_that.names,_that.coverDate,_that.storeDate,_that.focDate,_that.price,_that.priceCurrency,_that.rating,_that.sku,_that.isbn,_that.upc,_that.page,_that.description,_that.image,_that.coverHash,_that.arcs,_that.credits,_that.characters,_that.teams,_that.universes,_that.reprints,_that.variants,_that.cvId,_that.gcdId,_that.resourceUrl,_that.modified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  IssueDetailsNamedRef? publisher,  IssueDetailsNamedRef? imprint,  IssueDetailsSeries? series,  String number,  String? altNumber,  String? title,  List<String> names,  DateTime? coverDate,  DateTime? storeDate,  DateTime? focDate,  String? price,  String? priceCurrency,  IssueDetailsNamedRef? rating,  String? sku,  String? isbn,  String? upc,  int? page,  String? description,  String? image,  String? coverHash,  List<IssueDetailsParticipation> arcs,  List<IssueDetailsCredit> credits,  List<IssueDetailsParticipation> characters,  List<IssueDetailsParticipation> teams,  List<IssueDetailsParticipation> universes,  List<IssueDetailsReprint> reprints,  List<IssueDetailsVariant> variants,  int? cvId,  int? gcdId,  String? resourceUrl,  DateTime? modified)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetails() when $default != null:
return $default(_that.id,_that.publisher,_that.imprint,_that.series,_that.number,_that.altNumber,_that.title,_that.names,_that.coverDate,_that.storeDate,_that.focDate,_that.price,_that.priceCurrency,_that.rating,_that.sku,_that.isbn,_that.upc,_that.page,_that.description,_that.image,_that.coverHash,_that.arcs,_that.credits,_that.characters,_that.teams,_that.universes,_that.reprints,_that.variants,_that.cvId,_that.gcdId,_that.resourceUrl,_that.modified);case _:
  return null;

}
}

}

/// @nodoc


class _IssueDetails implements IssueDetails {
  const _IssueDetails({required this.id, this.publisher, this.imprint, this.series, required this.number, this.altNumber, this.title, final  List<String> names = const <String>[], this.coverDate, this.storeDate, this.focDate, this.price, this.priceCurrency, this.rating, this.sku, this.isbn, this.upc, this.page, this.description, this.image, this.coverHash, final  List<IssueDetailsParticipation> arcs = const <IssueDetailsParticipation>[], final  List<IssueDetailsCredit> credits = const <IssueDetailsCredit>[], final  List<IssueDetailsParticipation> characters = const <IssueDetailsParticipation>[], final  List<IssueDetailsParticipation> teams = const <IssueDetailsParticipation>[], final  List<IssueDetailsParticipation> universes = const <IssueDetailsParticipation>[], final  List<IssueDetailsReprint> reprints = const <IssueDetailsReprint>[], final  List<IssueDetailsVariant> variants = const <IssueDetailsVariant>[], this.cvId, this.gcdId, this.resourceUrl, this.modified}): _names = names,_arcs = arcs,_credits = credits,_characters = characters,_teams = teams,_universes = universes,_reprints = reprints,_variants = variants;
  

@override final  int id;
@override final  IssueDetailsNamedRef? publisher;
@override final  IssueDetailsNamedRef? imprint;
@override final  IssueDetailsSeries? series;
@override final  String number;
@override final  String? altNumber;
@override final  String? title;
 final  List<String> _names;
@override@JsonKey() List<String> get names {
  if (_names is EqualUnmodifiableListView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_names);
}

@override final  DateTime? coverDate;
@override final  DateTime? storeDate;
@override final  DateTime? focDate;
@override final  String? price;
@override final  String? priceCurrency;
@override final  IssueDetailsNamedRef? rating;
@override final  String? sku;
@override final  String? isbn;
@override final  String? upc;
@override final  int? page;
@override final  String? description;
@override final  String? image;
@override final  String? coverHash;
 final  List<IssueDetailsParticipation> _arcs;
@override@JsonKey() List<IssueDetailsParticipation> get arcs {
  if (_arcs is EqualUnmodifiableListView) return _arcs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_arcs);
}

 final  List<IssueDetailsCredit> _credits;
@override@JsonKey() List<IssueDetailsCredit> get credits {
  if (_credits is EqualUnmodifiableListView) return _credits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_credits);
}

 final  List<IssueDetailsParticipation> _characters;
@override@JsonKey() List<IssueDetailsParticipation> get characters {
  if (_characters is EqualUnmodifiableListView) return _characters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_characters);
}

 final  List<IssueDetailsParticipation> _teams;
@override@JsonKey() List<IssueDetailsParticipation> get teams {
  if (_teams is EqualUnmodifiableListView) return _teams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teams);
}

 final  List<IssueDetailsParticipation> _universes;
@override@JsonKey() List<IssueDetailsParticipation> get universes {
  if (_universes is EqualUnmodifiableListView) return _universes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_universes);
}

 final  List<IssueDetailsReprint> _reprints;
@override@JsonKey() List<IssueDetailsReprint> get reprints {
  if (_reprints is EqualUnmodifiableListView) return _reprints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reprints);
}

 final  List<IssueDetailsVariant> _variants;
@override@JsonKey() List<IssueDetailsVariant> get variants {
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_variants);
}

@override final  int? cvId;
@override final  int? gcdId;
@override final  String? resourceUrl;
@override final  DateTime? modified;

/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsCopyWith<_IssueDetails> get copyWith => __$IssueDetailsCopyWithImpl<_IssueDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.imprint, imprint) || other.imprint == imprint)&&(identical(other.series, series) || other.series == series)&&(identical(other.number, number) || other.number == number)&&(identical(other.altNumber, altNumber) || other.altNumber == altNumber)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._names, _names)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.focDate, focDate) || other.focDate == focDate)&&(identical(other.price, price) || other.price == price)&&(identical(other.priceCurrency, priceCurrency) || other.priceCurrency == priceCurrency)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.upc, upc) || other.upc == upc)&&(identical(other.page, page) || other.page == page)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.coverHash, coverHash) || other.coverHash == coverHash)&&const DeepCollectionEquality().equals(other._arcs, _arcs)&&const DeepCollectionEquality().equals(other._credits, _credits)&&const DeepCollectionEquality().equals(other._characters, _characters)&&const DeepCollectionEquality().equals(other._teams, _teams)&&const DeepCollectionEquality().equals(other._universes, _universes)&&const DeepCollectionEquality().equals(other._reprints, _reprints)&&const DeepCollectionEquality().equals(other._variants, _variants)&&(identical(other.cvId, cvId) || other.cvId == cvId)&&(identical(other.gcdId, gcdId) || other.gcdId == gcdId)&&(identical(other.resourceUrl, resourceUrl) || other.resourceUrl == resourceUrl)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,publisher,imprint,series,number,altNumber,title,const DeepCollectionEquality().hash(_names),coverDate,storeDate,focDate,price,priceCurrency,rating,sku,isbn,upc,page,description,image,coverHash,const DeepCollectionEquality().hash(_arcs),const DeepCollectionEquality().hash(_credits),const DeepCollectionEquality().hash(_characters),const DeepCollectionEquality().hash(_teams),const DeepCollectionEquality().hash(_universes),const DeepCollectionEquality().hash(_reprints),const DeepCollectionEquality().hash(_variants),cvId,gcdId,resourceUrl,modified]);

@override
String toString() {
  return 'IssueDetails(id: $id, publisher: $publisher, imprint: $imprint, series: $series, number: $number, altNumber: $altNumber, title: $title, names: $names, coverDate: $coverDate, storeDate: $storeDate, focDate: $focDate, price: $price, priceCurrency: $priceCurrency, rating: $rating, sku: $sku, isbn: $isbn, upc: $upc, page: $page, description: $description, image: $image, coverHash: $coverHash, arcs: $arcs, credits: $credits, characters: $characters, teams: $teams, universes: $universes, reprints: $reprints, variants: $variants, cvId: $cvId, gcdId: $gcdId, resourceUrl: $resourceUrl, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsCopyWith<$Res> implements $IssueDetailsCopyWith<$Res> {
  factory _$IssueDetailsCopyWith(_IssueDetails value, $Res Function(_IssueDetails) _then) = __$IssueDetailsCopyWithImpl;
@override @useResult
$Res call({
 int id, IssueDetailsNamedRef? publisher, IssueDetailsNamedRef? imprint, IssueDetailsSeries? series, String number, String? altNumber, String? title, List<String> names, DateTime? coverDate, DateTime? storeDate, DateTime? focDate, String? price, String? priceCurrency, IssueDetailsNamedRef? rating, String? sku, String? isbn, String? upc, int? page, String? description, String? image, String? coverHash, List<IssueDetailsParticipation> arcs, List<IssueDetailsCredit> credits, List<IssueDetailsParticipation> characters, List<IssueDetailsParticipation> teams, List<IssueDetailsParticipation> universes, List<IssueDetailsReprint> reprints, List<IssueDetailsVariant> variants, int? cvId, int? gcdId, String? resourceUrl, DateTime? modified
});


@override $IssueDetailsNamedRefCopyWith<$Res>? get publisher;@override $IssueDetailsNamedRefCopyWith<$Res>? get imprint;@override $IssueDetailsSeriesCopyWith<$Res>? get series;@override $IssueDetailsNamedRefCopyWith<$Res>? get rating;

}
/// @nodoc
class __$IssueDetailsCopyWithImpl<$Res>
    implements _$IssueDetailsCopyWith<$Res> {
  __$IssueDetailsCopyWithImpl(this._self, this._then);

  final _IssueDetails _self;
  final $Res Function(_IssueDetails) _then;

/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publisher = freezed,Object? imprint = freezed,Object? series = freezed,Object? number = null,Object? altNumber = freezed,Object? title = freezed,Object? names = null,Object? coverDate = freezed,Object? storeDate = freezed,Object? focDate = freezed,Object? price = freezed,Object? priceCurrency = freezed,Object? rating = freezed,Object? sku = freezed,Object? isbn = freezed,Object? upc = freezed,Object? page = freezed,Object? description = freezed,Object? image = freezed,Object? coverHash = freezed,Object? arcs = null,Object? credits = null,Object? characters = null,Object? teams = null,Object? universes = null,Object? reprints = null,Object? variants = null,Object? cvId = freezed,Object? gcdId = freezed,Object? resourceUrl = freezed,Object? modified = freezed,}) {
  return _then(_IssueDetails(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRef?,imprint: freezed == imprint ? _self.imprint : imprint // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRef?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as IssueDetailsSeries?,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,altNumber: freezed == altNumber ? _self.altNumber : altNumber // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,names: null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as List<String>,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as DateTime?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,focDate: freezed == focDate ? _self.focDate : focDate // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,priceCurrency: freezed == priceCurrency ? _self.priceCurrency : priceCurrency // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRef?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,upc: freezed == upc ? _self.upc : upc // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,coverHash: freezed == coverHash ? _self.coverHash : coverHash // ignore: cast_nullable_to_non_nullable
as String?,arcs: null == arcs ? _self._arcs : arcs // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipation>,credits: null == credits ? _self._credits : credits // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsCredit>,characters: null == characters ? _self._characters : characters // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipation>,teams: null == teams ? _self._teams : teams // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipation>,universes: null == universes ? _self._universes : universes // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipation>,reprints: null == reprints ? _self._reprints : reprints // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsReprint>,variants: null == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsVariant>,cvId: freezed == cvId ? _self.cvId : cvId // ignore: cast_nullable_to_non_nullable
as int?,gcdId: freezed == gcdId ? _self.gcdId : gcdId // ignore: cast_nullable_to_non_nullable
as int?,resourceUrl: freezed == resourceUrl ? _self.resourceUrl : resourceUrl // ignore: cast_nullable_to_non_nullable
as String?,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $IssueDetailsNamedRefCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<$Res>? get imprint {
    if (_self.imprint == null) {
    return null;
  }

  return $IssueDetailsNamedRefCopyWith<$Res>(_self.imprint!, (value) {
    return _then(_self.copyWith(imprint: value));
  });
}/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsSeriesCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $IssueDetailsSeriesCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of IssueDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $IssueDetailsNamedRefCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}

/// @nodoc
mixin _$IssueDetailsNamedRef {

 int get id; String get name;
/// Create a copy of IssueDetailsNamedRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<IssueDetailsNamedRef> get copyWith => _$IssueDetailsNamedRefCopyWithImpl<IssueDetailsNamedRef>(this as IssueDetailsNamedRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsNamedRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IssueDetailsNamedRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsNamedRefCopyWith<$Res>  {
  factory $IssueDetailsNamedRefCopyWith(IssueDetailsNamedRef value, $Res Function(IssueDetailsNamedRef) _then) = _$IssueDetailsNamedRefCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$IssueDetailsNamedRefCopyWithImpl<$Res>
    implements $IssueDetailsNamedRefCopyWith<$Res> {
  _$IssueDetailsNamedRefCopyWithImpl(this._self, this._then);

  final IssueDetailsNamedRef _self;
  final $Res Function(IssueDetailsNamedRef) _then;

/// Create a copy of IssueDetailsNamedRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsNamedRef].
extension IssueDetailsNamedRefPatterns on IssueDetailsNamedRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsNamedRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsNamedRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsNamedRef value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsNamedRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsNamedRef value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsNamedRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsNamedRef() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsNamedRef():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsNamedRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _IssueDetailsNamedRef implements IssueDetailsNamedRef {
  const _IssueDetailsNamedRef({required this.id, required this.name});
  

@override final  int id;
@override final  String name;

/// Create a copy of IssueDetailsNamedRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsNamedRefCopyWith<_IssueDetailsNamedRef> get copyWith => __$IssueDetailsNamedRefCopyWithImpl<_IssueDetailsNamedRef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsNamedRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IssueDetailsNamedRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsNamedRefCopyWith<$Res> implements $IssueDetailsNamedRefCopyWith<$Res> {
  factory _$IssueDetailsNamedRefCopyWith(_IssueDetailsNamedRef value, $Res Function(_IssueDetailsNamedRef) _then) = __$IssueDetailsNamedRefCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$IssueDetailsNamedRefCopyWithImpl<$Res>
    implements _$IssueDetailsNamedRefCopyWith<$Res> {
  __$IssueDetailsNamedRefCopyWithImpl(this._self, this._then);

  final _IssueDetailsNamedRef _self;
  final $Res Function(_IssueDetailsNamedRef) _then;

/// Create a copy of IssueDetailsNamedRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_IssueDetailsNamedRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$IssueDetailsSeries {

 int get id; String get name; String? get sortName; int? get volume; int? get yearBegan; IssueDetailsNamedRef? get seriesType; List<IssueDetailsNamedRef> get genres;
/// Create a copy of IssueDetailsSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsSeriesCopyWith<IssueDetailsSeries> get copyWith => _$IssueDetailsSeriesCopyWithImpl<IssueDetailsSeries>(this as IssueDetailsSeries, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsSeries&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortName, sortName) || other.sortName == sortName)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.seriesType, seriesType) || other.seriesType == seriesType)&&const DeepCollectionEquality().equals(other.genres, genres));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,sortName,volume,yearBegan,seriesType,const DeepCollectionEquality().hash(genres));

@override
String toString() {
  return 'IssueDetailsSeries(id: $id, name: $name, sortName: $sortName, volume: $volume, yearBegan: $yearBegan, seriesType: $seriesType, genres: $genres)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsSeriesCopyWith<$Res>  {
  factory $IssueDetailsSeriesCopyWith(IssueDetailsSeries value, $Res Function(IssueDetailsSeries) _then) = _$IssueDetailsSeriesCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? sortName, int? volume, int? yearBegan, IssueDetailsNamedRef? seriesType, List<IssueDetailsNamedRef> genres
});


$IssueDetailsNamedRefCopyWith<$Res>? get seriesType;

}
/// @nodoc
class _$IssueDetailsSeriesCopyWithImpl<$Res>
    implements $IssueDetailsSeriesCopyWith<$Res> {
  _$IssueDetailsSeriesCopyWithImpl(this._self, this._then);

  final IssueDetailsSeries _self;
  final $Res Function(IssueDetailsSeries) _then;

/// Create a copy of IssueDetailsSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sortName = freezed,Object? volume = freezed,Object? yearBegan = freezed,Object? seriesType = freezed,Object? genres = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortName: freezed == sortName ? _self.sortName : sortName // ignore: cast_nullable_to_non_nullable
as String?,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int?,yearBegan: freezed == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int?,seriesType: freezed == seriesType ? _self.seriesType : seriesType // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRef?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsNamedRef>,
  ));
}
/// Create a copy of IssueDetailsSeries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<$Res>? get seriesType {
    if (_self.seriesType == null) {
    return null;
  }

  return $IssueDetailsNamedRefCopyWith<$Res>(_self.seriesType!, (value) {
    return _then(_self.copyWith(seriesType: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueDetailsSeries].
extension IssueDetailsSeriesPatterns on IssueDetailsSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsSeries value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsSeries value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? sortName,  int? volume,  int? yearBegan,  IssueDetailsNamedRef? seriesType,  List<IssueDetailsNamedRef> genres)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsSeries() when $default != null:
return $default(_that.id,_that.name,_that.sortName,_that.volume,_that.yearBegan,_that.seriesType,_that.genres);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? sortName,  int? volume,  int? yearBegan,  IssueDetailsNamedRef? seriesType,  List<IssueDetailsNamedRef> genres)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsSeries():
return $default(_that.id,_that.name,_that.sortName,_that.volume,_that.yearBegan,_that.seriesType,_that.genres);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? sortName,  int? volume,  int? yearBegan,  IssueDetailsNamedRef? seriesType,  List<IssueDetailsNamedRef> genres)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsSeries() when $default != null:
return $default(_that.id,_that.name,_that.sortName,_that.volume,_that.yearBegan,_that.seriesType,_that.genres);case _:
  return null;

}
}

}

/// @nodoc


class _IssueDetailsSeries implements IssueDetailsSeries {
  const _IssueDetailsSeries({required this.id, required this.name, this.sortName, this.volume, this.yearBegan, this.seriesType, final  List<IssueDetailsNamedRef> genres = const <IssueDetailsNamedRef>[]}): _genres = genres;
  

@override final  int id;
@override final  String name;
@override final  String? sortName;
@override final  int? volume;
@override final  int? yearBegan;
@override final  IssueDetailsNamedRef? seriesType;
 final  List<IssueDetailsNamedRef> _genres;
@override@JsonKey() List<IssueDetailsNamedRef> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}


/// Create a copy of IssueDetailsSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsSeriesCopyWith<_IssueDetailsSeries> get copyWith => __$IssueDetailsSeriesCopyWithImpl<_IssueDetailsSeries>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsSeries&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortName, sortName) || other.sortName == sortName)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.seriesType, seriesType) || other.seriesType == seriesType)&&const DeepCollectionEquality().equals(other._genres, _genres));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,sortName,volume,yearBegan,seriesType,const DeepCollectionEquality().hash(_genres));

@override
String toString() {
  return 'IssueDetailsSeries(id: $id, name: $name, sortName: $sortName, volume: $volume, yearBegan: $yearBegan, seriesType: $seriesType, genres: $genres)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsSeriesCopyWith<$Res> implements $IssueDetailsSeriesCopyWith<$Res> {
  factory _$IssueDetailsSeriesCopyWith(_IssueDetailsSeries value, $Res Function(_IssueDetailsSeries) _then) = __$IssueDetailsSeriesCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? sortName, int? volume, int? yearBegan, IssueDetailsNamedRef? seriesType, List<IssueDetailsNamedRef> genres
});


@override $IssueDetailsNamedRefCopyWith<$Res>? get seriesType;

}
/// @nodoc
class __$IssueDetailsSeriesCopyWithImpl<$Res>
    implements _$IssueDetailsSeriesCopyWith<$Res> {
  __$IssueDetailsSeriesCopyWithImpl(this._self, this._then);

  final _IssueDetailsSeries _self;
  final $Res Function(_IssueDetailsSeries) _then;

/// Create a copy of IssueDetailsSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sortName = freezed,Object? volume = freezed,Object? yearBegan = freezed,Object? seriesType = freezed,Object? genres = null,}) {
  return _then(_IssueDetailsSeries(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortName: freezed == sortName ? _self.sortName : sortName // ignore: cast_nullable_to_non_nullable
as String?,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int?,yearBegan: freezed == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int?,seriesType: freezed == seriesType ? _self.seriesType : seriesType // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRef?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsNamedRef>,
  ));
}

/// Create a copy of IssueDetailsSeries
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefCopyWith<$Res>? get seriesType {
    if (_self.seriesType == null) {
    return null;
  }

  return $IssueDetailsNamedRefCopyWith<$Res>(_self.seriesType!, (value) {
    return _then(_self.copyWith(seriesType: value));
  });
}
}

/// @nodoc
mixin _$IssueDetailsParticipation {

 int get id; String get name; DateTime? get modified;
/// Create a copy of IssueDetailsParticipation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsParticipationCopyWith<IssueDetailsParticipation> get copyWith => _$IssueDetailsParticipationCopyWithImpl<IssueDetailsParticipation>(this as IssueDetailsParticipation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsParticipation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,modified);

@override
String toString() {
  return 'IssueDetailsParticipation(id: $id, name: $name, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsParticipationCopyWith<$Res>  {
  factory $IssueDetailsParticipationCopyWith(IssueDetailsParticipation value, $Res Function(IssueDetailsParticipation) _then) = _$IssueDetailsParticipationCopyWithImpl;
@useResult
$Res call({
 int id, String name, DateTime? modified
});




}
/// @nodoc
class _$IssueDetailsParticipationCopyWithImpl<$Res>
    implements $IssueDetailsParticipationCopyWith<$Res> {
  _$IssueDetailsParticipationCopyWithImpl(this._self, this._then);

  final IssueDetailsParticipation _self;
  final $Res Function(IssueDetailsParticipation) _then;

/// Create a copy of IssueDetailsParticipation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? modified = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsParticipation].
extension IssueDetailsParticipationPatterns on IssueDetailsParticipation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsParticipation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsParticipation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsParticipation value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsParticipation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsParticipation value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsParticipation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  DateTime? modified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsParticipation() when $default != null:
return $default(_that.id,_that.name,_that.modified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  DateTime? modified)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsParticipation():
return $default(_that.id,_that.name,_that.modified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  DateTime? modified)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsParticipation() when $default != null:
return $default(_that.id,_that.name,_that.modified);case _:
  return null;

}
}

}

/// @nodoc


class _IssueDetailsParticipation implements IssueDetailsParticipation {
  const _IssueDetailsParticipation({required this.id, required this.name, this.modified});
  

@override final  int id;
@override final  String name;
@override final  DateTime? modified;

/// Create a copy of IssueDetailsParticipation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsParticipationCopyWith<_IssueDetailsParticipation> get copyWith => __$IssueDetailsParticipationCopyWithImpl<_IssueDetailsParticipation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsParticipation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,modified);

@override
String toString() {
  return 'IssueDetailsParticipation(id: $id, name: $name, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsParticipationCopyWith<$Res> implements $IssueDetailsParticipationCopyWith<$Res> {
  factory _$IssueDetailsParticipationCopyWith(_IssueDetailsParticipation value, $Res Function(_IssueDetailsParticipation) _then) = __$IssueDetailsParticipationCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, DateTime? modified
});




}
/// @nodoc
class __$IssueDetailsParticipationCopyWithImpl<$Res>
    implements _$IssueDetailsParticipationCopyWith<$Res> {
  __$IssueDetailsParticipationCopyWithImpl(this._self, this._then);

  final _IssueDetailsParticipation _self;
  final $Res Function(_IssueDetailsParticipation) _then;

/// Create a copy of IssueDetailsParticipation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? modified = freezed,}) {
  return _then(_IssueDetailsParticipation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$IssueDetailsCreditRole {

 int get id; String get name;
/// Create a copy of IssueDetailsCreditRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsCreditRoleCopyWith<IssueDetailsCreditRole> get copyWith => _$IssueDetailsCreditRoleCopyWithImpl<IssueDetailsCreditRole>(this as IssueDetailsCreditRole, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsCreditRole&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IssueDetailsCreditRole(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsCreditRoleCopyWith<$Res>  {
  factory $IssueDetailsCreditRoleCopyWith(IssueDetailsCreditRole value, $Res Function(IssueDetailsCreditRole) _then) = _$IssueDetailsCreditRoleCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$IssueDetailsCreditRoleCopyWithImpl<$Res>
    implements $IssueDetailsCreditRoleCopyWith<$Res> {
  _$IssueDetailsCreditRoleCopyWithImpl(this._self, this._then);

  final IssueDetailsCreditRole _self;
  final $Res Function(IssueDetailsCreditRole) _then;

/// Create a copy of IssueDetailsCreditRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsCreditRole].
extension IssueDetailsCreditRolePatterns on IssueDetailsCreditRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsCreditRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsCreditRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsCreditRole value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsCreditRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsCreditRole value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsCreditRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsCreditRole() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsCreditRole():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsCreditRole() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _IssueDetailsCreditRole implements IssueDetailsCreditRole {
  const _IssueDetailsCreditRole({required this.id, required this.name});
  

@override final  int id;
@override final  String name;

/// Create a copy of IssueDetailsCreditRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsCreditRoleCopyWith<_IssueDetailsCreditRole> get copyWith => __$IssueDetailsCreditRoleCopyWithImpl<_IssueDetailsCreditRole>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsCreditRole&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IssueDetailsCreditRole(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsCreditRoleCopyWith<$Res> implements $IssueDetailsCreditRoleCopyWith<$Res> {
  factory _$IssueDetailsCreditRoleCopyWith(_IssueDetailsCreditRole value, $Res Function(_IssueDetailsCreditRole) _then) = __$IssueDetailsCreditRoleCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$IssueDetailsCreditRoleCopyWithImpl<$Res>
    implements _$IssueDetailsCreditRoleCopyWith<$Res> {
  __$IssueDetailsCreditRoleCopyWithImpl(this._self, this._then);

  final _IssueDetailsCreditRole _self;
  final $Res Function(_IssueDetailsCreditRole) _then;

/// Create a copy of IssueDetailsCreditRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_IssueDetailsCreditRole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$IssueDetailsCredit {

 int get id; String? get creator; List<IssueDetailsCreditRole> get roles;
/// Create a copy of IssueDetailsCredit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsCreditCopyWith<IssueDetailsCredit> get copyWith => _$IssueDetailsCreditCopyWithImpl<IssueDetailsCredit>(this as IssueDetailsCredit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsCredit&&(identical(other.id, id) || other.id == id)&&(identical(other.creator, creator) || other.creator == creator)&&const DeepCollectionEquality().equals(other.roles, roles));
}


@override
int get hashCode => Object.hash(runtimeType,id,creator,const DeepCollectionEquality().hash(roles));

@override
String toString() {
  return 'IssueDetailsCredit(id: $id, creator: $creator, roles: $roles)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsCreditCopyWith<$Res>  {
  factory $IssueDetailsCreditCopyWith(IssueDetailsCredit value, $Res Function(IssueDetailsCredit) _then) = _$IssueDetailsCreditCopyWithImpl;
@useResult
$Res call({
 int id, String? creator, List<IssueDetailsCreditRole> roles
});




}
/// @nodoc
class _$IssueDetailsCreditCopyWithImpl<$Res>
    implements $IssueDetailsCreditCopyWith<$Res> {
  _$IssueDetailsCreditCopyWithImpl(this._self, this._then);

  final IssueDetailsCredit _self;
  final $Res Function(IssueDetailsCredit) _then;

/// Create a copy of IssueDetailsCredit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creator = freezed,Object? roles = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsCreditRole>,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsCredit].
extension IssueDetailsCreditPatterns on IssueDetailsCredit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsCredit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsCredit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsCredit value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsCredit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsCredit value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsCredit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? creator,  List<IssueDetailsCreditRole> roles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsCredit() when $default != null:
return $default(_that.id,_that.creator,_that.roles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? creator,  List<IssueDetailsCreditRole> roles)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsCredit():
return $default(_that.id,_that.creator,_that.roles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? creator,  List<IssueDetailsCreditRole> roles)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsCredit() when $default != null:
return $default(_that.id,_that.creator,_that.roles);case _:
  return null;

}
}

}

/// @nodoc


class _IssueDetailsCredit implements IssueDetailsCredit {
  const _IssueDetailsCredit({required this.id, this.creator, final  List<IssueDetailsCreditRole> roles = const <IssueDetailsCreditRole>[]}): _roles = roles;
  

@override final  int id;
@override final  String? creator;
 final  List<IssueDetailsCreditRole> _roles;
@override@JsonKey() List<IssueDetailsCreditRole> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}


/// Create a copy of IssueDetailsCredit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsCreditCopyWith<_IssueDetailsCredit> get copyWith => __$IssueDetailsCreditCopyWithImpl<_IssueDetailsCredit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsCredit&&(identical(other.id, id) || other.id == id)&&(identical(other.creator, creator) || other.creator == creator)&&const DeepCollectionEquality().equals(other._roles, _roles));
}


@override
int get hashCode => Object.hash(runtimeType,id,creator,const DeepCollectionEquality().hash(_roles));

@override
String toString() {
  return 'IssueDetailsCredit(id: $id, creator: $creator, roles: $roles)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsCreditCopyWith<$Res> implements $IssueDetailsCreditCopyWith<$Res> {
  factory _$IssueDetailsCreditCopyWith(_IssueDetailsCredit value, $Res Function(_IssueDetailsCredit) _then) = __$IssueDetailsCreditCopyWithImpl;
@override @useResult
$Res call({
 int id, String? creator, List<IssueDetailsCreditRole> roles
});




}
/// @nodoc
class __$IssueDetailsCreditCopyWithImpl<$Res>
    implements _$IssueDetailsCreditCopyWith<$Res> {
  __$IssueDetailsCreditCopyWithImpl(this._self, this._then);

  final _IssueDetailsCredit _self;
  final $Res Function(_IssueDetailsCredit) _then;

/// Create a copy of IssueDetailsCredit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creator = freezed,Object? roles = null,}) {
  return _then(_IssueDetailsCredit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsCreditRole>,
  ));
}


}

/// @nodoc
mixin _$IssueDetailsReprint {

 int get id; String? get issue;
/// Create a copy of IssueDetailsReprint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsReprintCopyWith<IssueDetailsReprint> get copyWith => _$IssueDetailsReprintCopyWithImpl<IssueDetailsReprint>(this as IssueDetailsReprint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsReprint&&(identical(other.id, id) || other.id == id)&&(identical(other.issue, issue) || other.issue == issue));
}


@override
int get hashCode => Object.hash(runtimeType,id,issue);

@override
String toString() {
  return 'IssueDetailsReprint(id: $id, issue: $issue)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsReprintCopyWith<$Res>  {
  factory $IssueDetailsReprintCopyWith(IssueDetailsReprint value, $Res Function(IssueDetailsReprint) _then) = _$IssueDetailsReprintCopyWithImpl;
@useResult
$Res call({
 int id, String? issue
});




}
/// @nodoc
class _$IssueDetailsReprintCopyWithImpl<$Res>
    implements $IssueDetailsReprintCopyWith<$Res> {
  _$IssueDetailsReprintCopyWithImpl(this._self, this._then);

  final IssueDetailsReprint _self;
  final $Res Function(IssueDetailsReprint) _then;

/// Create a copy of IssueDetailsReprint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? issue = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,issue: freezed == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsReprint].
extension IssueDetailsReprintPatterns on IssueDetailsReprint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsReprint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsReprint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsReprint value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsReprint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsReprint value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsReprint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? issue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsReprint() when $default != null:
return $default(_that.id,_that.issue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? issue)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsReprint():
return $default(_that.id,_that.issue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? issue)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsReprint() when $default != null:
return $default(_that.id,_that.issue);case _:
  return null;

}
}

}

/// @nodoc


class _IssueDetailsReprint implements IssueDetailsReprint {
  const _IssueDetailsReprint({required this.id, this.issue});
  

@override final  int id;
@override final  String? issue;

/// Create a copy of IssueDetailsReprint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsReprintCopyWith<_IssueDetailsReprint> get copyWith => __$IssueDetailsReprintCopyWithImpl<_IssueDetailsReprint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsReprint&&(identical(other.id, id) || other.id == id)&&(identical(other.issue, issue) || other.issue == issue));
}


@override
int get hashCode => Object.hash(runtimeType,id,issue);

@override
String toString() {
  return 'IssueDetailsReprint(id: $id, issue: $issue)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsReprintCopyWith<$Res> implements $IssueDetailsReprintCopyWith<$Res> {
  factory _$IssueDetailsReprintCopyWith(_IssueDetailsReprint value, $Res Function(_IssueDetailsReprint) _then) = __$IssueDetailsReprintCopyWithImpl;
@override @useResult
$Res call({
 int id, String? issue
});




}
/// @nodoc
class __$IssueDetailsReprintCopyWithImpl<$Res>
    implements _$IssueDetailsReprintCopyWith<$Res> {
  __$IssueDetailsReprintCopyWithImpl(this._self, this._then);

  final _IssueDetailsReprint _self;
  final $Res Function(_IssueDetailsReprint) _then;

/// Create a copy of IssueDetailsReprint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? issue = freezed,}) {
  return _then(_IssueDetailsReprint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,issue: freezed == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$IssueDetailsVariant {

 String? get name; String? get price; String? get sku; String? get upc; String? get image;
/// Create a copy of IssueDetailsVariant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsVariantCopyWith<IssueDetailsVariant> get copyWith => _$IssueDetailsVariantCopyWithImpl<IssueDetailsVariant>(this as IssueDetailsVariant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsVariant&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.upc, upc) || other.upc == upc)&&(identical(other.image, image) || other.image == image));
}


@override
int get hashCode => Object.hash(runtimeType,name,price,sku,upc,image);

@override
String toString() {
  return 'IssueDetailsVariant(name: $name, price: $price, sku: $sku, upc: $upc, image: $image)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsVariantCopyWith<$Res>  {
  factory $IssueDetailsVariantCopyWith(IssueDetailsVariant value, $Res Function(IssueDetailsVariant) _then) = _$IssueDetailsVariantCopyWithImpl;
@useResult
$Res call({
 String? name, String? price, String? sku, String? upc, String? image
});




}
/// @nodoc
class _$IssueDetailsVariantCopyWithImpl<$Res>
    implements $IssueDetailsVariantCopyWith<$Res> {
  _$IssueDetailsVariantCopyWithImpl(this._self, this._then);

  final IssueDetailsVariant _self;
  final $Res Function(IssueDetailsVariant) _then;

/// Create a copy of IssueDetailsVariant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? price = freezed,Object? sku = freezed,Object? upc = freezed,Object? image = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,upc: freezed == upc ? _self.upc : upc // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsVariant].
extension IssueDetailsVariantPatterns on IssueDetailsVariant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsVariant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsVariant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsVariant value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsVariant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsVariant value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsVariant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? price,  String? sku,  String? upc,  String? image)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsVariant() when $default != null:
return $default(_that.name,_that.price,_that.sku,_that.upc,_that.image);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? price,  String? sku,  String? upc,  String? image)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsVariant():
return $default(_that.name,_that.price,_that.sku,_that.upc,_that.image);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? price,  String? sku,  String? upc,  String? image)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsVariant() when $default != null:
return $default(_that.name,_that.price,_that.sku,_that.upc,_that.image);case _:
  return null;

}
}

}

/// @nodoc


class _IssueDetailsVariant implements IssueDetailsVariant {
  const _IssueDetailsVariant({this.name, this.price, this.sku, this.upc, this.image});
  

@override final  String? name;
@override final  String? price;
@override final  String? sku;
@override final  String? upc;
@override final  String? image;

/// Create a copy of IssueDetailsVariant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsVariantCopyWith<_IssueDetailsVariant> get copyWith => __$IssueDetailsVariantCopyWithImpl<_IssueDetailsVariant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsVariant&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.upc, upc) || other.upc == upc)&&(identical(other.image, image) || other.image == image));
}


@override
int get hashCode => Object.hash(runtimeType,name,price,sku,upc,image);

@override
String toString() {
  return 'IssueDetailsVariant(name: $name, price: $price, sku: $sku, upc: $upc, image: $image)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsVariantCopyWith<$Res> implements $IssueDetailsVariantCopyWith<$Res> {
  factory _$IssueDetailsVariantCopyWith(_IssueDetailsVariant value, $Res Function(_IssueDetailsVariant) _then) = __$IssueDetailsVariantCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? price, String? sku, String? upc, String? image
});




}
/// @nodoc
class __$IssueDetailsVariantCopyWithImpl<$Res>
    implements _$IssueDetailsVariantCopyWith<$Res> {
  __$IssueDetailsVariantCopyWithImpl(this._self, this._then);

  final _IssueDetailsVariant _self;
  final $Res Function(_IssueDetailsVariant) _then;

/// Create a copy of IssueDetailsVariant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? price = freezed,Object? sku = freezed,Object? upc = freezed,Object? image = freezed,}) {
  return _then(_IssueDetailsVariant(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,upc: freezed == upc ? _self.upc : upc // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
