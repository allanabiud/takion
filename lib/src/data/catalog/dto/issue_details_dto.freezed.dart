// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_details_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IssueDetailsDto {

 int get id; IssueDetailsNamedRefDto? get publisher; IssueDetailsNamedRefDto? get imprint; IssueDetailsSeriesDto? get series; String get number;@JsonKey(name: 'alt_number') String? get altNumber; String? get title;@JsonKey(name: 'name') List<String> get names;@JsonKey(name: 'cover_date') String? get coverDate;@JsonKey(name: 'store_date') String? get storeDate;@JsonKey(name: 'foc_date') String? get focDate; String? get price;@JsonKey(name: 'price_currency') String? get priceCurrency; IssueDetailsNamedRefDto? get rating; String? get sku; String? get isbn; String? get upc;@JsonKey(name: 'page') int? get page;@JsonKey(name: 'desc') String? get description; String? get image;@JsonKey(name: 'cover_hash') String? get coverHash;@JsonKey(name: 'arcs') List<IssueDetailsParticipationDto> get arcs;@JsonKey(name: 'credits') List<IssueDetailsCreditDto> get credits;@JsonKey(name: 'characters') List<IssueDetailsParticipationDto> get characters;@JsonKey(name: 'teams') List<IssueDetailsParticipationDto> get teams;@JsonKey(name: 'universes') List<IssueDetailsParticipationDto> get universes;@JsonKey(name: 'reprints') List<IssueDetailsReprintDto> get reprints;@JsonKey(name: 'variants') List<IssueDetailsVariantDto> get variants;@JsonKey(name: 'cv_id') int? get cvId;@JsonKey(name: 'gcd_id') int? get gcdId;@JsonKey(name: 'resource_url') String? get resourceUrl; String? get modified;
/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsDtoCopyWith<IssueDetailsDto> get copyWith => _$IssueDetailsDtoCopyWithImpl<IssueDetailsDto>(this as IssueDetailsDto, _$identity);

  /// Serializes this IssueDetailsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.imprint, imprint) || other.imprint == imprint)&&(identical(other.series, series) || other.series == series)&&(identical(other.number, number) || other.number == number)&&(identical(other.altNumber, altNumber) || other.altNumber == altNumber)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.names, names)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.focDate, focDate) || other.focDate == focDate)&&(identical(other.price, price) || other.price == price)&&(identical(other.priceCurrency, priceCurrency) || other.priceCurrency == priceCurrency)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.upc, upc) || other.upc == upc)&&(identical(other.page, page) || other.page == page)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.coverHash, coverHash) || other.coverHash == coverHash)&&const DeepCollectionEquality().equals(other.arcs, arcs)&&const DeepCollectionEquality().equals(other.credits, credits)&&const DeepCollectionEquality().equals(other.characters, characters)&&const DeepCollectionEquality().equals(other.teams, teams)&&const DeepCollectionEquality().equals(other.universes, universes)&&const DeepCollectionEquality().equals(other.reprints, reprints)&&const DeepCollectionEquality().equals(other.variants, variants)&&(identical(other.cvId, cvId) || other.cvId == cvId)&&(identical(other.gcdId, gcdId) || other.gcdId == gcdId)&&(identical(other.resourceUrl, resourceUrl) || other.resourceUrl == resourceUrl)&&(identical(other.modified, modified) || other.modified == modified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,publisher,imprint,series,number,altNumber,title,const DeepCollectionEquality().hash(names),coverDate,storeDate,focDate,price,priceCurrency,rating,sku,isbn,upc,page,description,image,coverHash,const DeepCollectionEquality().hash(arcs),const DeepCollectionEquality().hash(credits),const DeepCollectionEquality().hash(characters),const DeepCollectionEquality().hash(teams),const DeepCollectionEquality().hash(universes),const DeepCollectionEquality().hash(reprints),const DeepCollectionEquality().hash(variants),cvId,gcdId,resourceUrl,modified]);

@override
String toString() {
  return 'IssueDetailsDto(id: $id, publisher: $publisher, imprint: $imprint, series: $series, number: $number, altNumber: $altNumber, title: $title, names: $names, coverDate: $coverDate, storeDate: $storeDate, focDate: $focDate, price: $price, priceCurrency: $priceCurrency, rating: $rating, sku: $sku, isbn: $isbn, upc: $upc, page: $page, description: $description, image: $image, coverHash: $coverHash, arcs: $arcs, credits: $credits, characters: $characters, teams: $teams, universes: $universes, reprints: $reprints, variants: $variants, cvId: $cvId, gcdId: $gcdId, resourceUrl: $resourceUrl, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsDtoCopyWith<$Res>  {
  factory $IssueDetailsDtoCopyWith(IssueDetailsDto value, $Res Function(IssueDetailsDto) _then) = _$IssueDetailsDtoCopyWithImpl;
@useResult
$Res call({
 int id, IssueDetailsNamedRefDto? publisher, IssueDetailsNamedRefDto? imprint, IssueDetailsSeriesDto? series, String number,@JsonKey(name: 'alt_number') String? altNumber, String? title,@JsonKey(name: 'name') List<String> names,@JsonKey(name: 'cover_date') String? coverDate,@JsonKey(name: 'store_date') String? storeDate,@JsonKey(name: 'foc_date') String? focDate, String? price,@JsonKey(name: 'price_currency') String? priceCurrency, IssueDetailsNamedRefDto? rating, String? sku, String? isbn, String? upc,@JsonKey(name: 'page') int? page,@JsonKey(name: 'desc') String? description, String? image,@JsonKey(name: 'cover_hash') String? coverHash,@JsonKey(name: 'arcs') List<IssueDetailsParticipationDto> arcs,@JsonKey(name: 'credits') List<IssueDetailsCreditDto> credits,@JsonKey(name: 'characters') List<IssueDetailsParticipationDto> characters,@JsonKey(name: 'teams') List<IssueDetailsParticipationDto> teams,@JsonKey(name: 'universes') List<IssueDetailsParticipationDto> universes,@JsonKey(name: 'reprints') List<IssueDetailsReprintDto> reprints,@JsonKey(name: 'variants') List<IssueDetailsVariantDto> variants,@JsonKey(name: 'cv_id') int? cvId,@JsonKey(name: 'gcd_id') int? gcdId,@JsonKey(name: 'resource_url') String? resourceUrl, String? modified
});


$IssueDetailsNamedRefDtoCopyWith<$Res>? get publisher;$IssueDetailsNamedRefDtoCopyWith<$Res>? get imprint;$IssueDetailsSeriesDtoCopyWith<$Res>? get series;$IssueDetailsNamedRefDtoCopyWith<$Res>? get rating;

}
/// @nodoc
class _$IssueDetailsDtoCopyWithImpl<$Res>
    implements $IssueDetailsDtoCopyWith<$Res> {
  _$IssueDetailsDtoCopyWithImpl(this._self, this._then);

  final IssueDetailsDto _self;
  final $Res Function(IssueDetailsDto) _then;

/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publisher = freezed,Object? imprint = freezed,Object? series = freezed,Object? number = null,Object? altNumber = freezed,Object? title = freezed,Object? names = null,Object? coverDate = freezed,Object? storeDate = freezed,Object? focDate = freezed,Object? price = freezed,Object? priceCurrency = freezed,Object? rating = freezed,Object? sku = freezed,Object? isbn = freezed,Object? upc = freezed,Object? page = freezed,Object? description = freezed,Object? image = freezed,Object? coverHash = freezed,Object? arcs = null,Object? credits = null,Object? characters = null,Object? teams = null,Object? universes = null,Object? reprints = null,Object? variants = null,Object? cvId = freezed,Object? gcdId = freezed,Object? resourceUrl = freezed,Object? modified = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRefDto?,imprint: freezed == imprint ? _self.imprint : imprint // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRefDto?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as IssueDetailsSeriesDto?,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,altNumber: freezed == altNumber ? _self.altNumber : altNumber // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as List<String>,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as String?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as String?,focDate: freezed == focDate ? _self.focDate : focDate // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,priceCurrency: freezed == priceCurrency ? _self.priceCurrency : priceCurrency // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRefDto?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,upc: freezed == upc ? _self.upc : upc // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,coverHash: freezed == coverHash ? _self.coverHash : coverHash // ignore: cast_nullable_to_non_nullable
as String?,arcs: null == arcs ? _self.arcs : arcs // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipationDto>,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsCreditDto>,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipationDto>,teams: null == teams ? _self.teams : teams // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipationDto>,universes: null == universes ? _self.universes : universes // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipationDto>,reprints: null == reprints ? _self.reprints : reprints // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsReprintDto>,variants: null == variants ? _self.variants : variants // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsVariantDto>,cvId: freezed == cvId ? _self.cvId : cvId // ignore: cast_nullable_to_non_nullable
as int?,gcdId: freezed == gcdId ? _self.gcdId : gcdId // ignore: cast_nullable_to_non_nullable
as int?,resourceUrl: freezed == resourceUrl ? _self.resourceUrl : resourceUrl // ignore: cast_nullable_to_non_nullable
as String?,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $IssueDetailsNamedRefDtoCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<$Res>? get imprint {
    if (_self.imprint == null) {
    return null;
  }

  return $IssueDetailsNamedRefDtoCopyWith<$Res>(_self.imprint!, (value) {
    return _then(_self.copyWith(imprint: value));
  });
}/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsSeriesDtoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $IssueDetailsSeriesDtoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $IssueDetailsNamedRefDtoCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueDetailsDto].
extension IssueDetailsDtoPatterns on IssueDetailsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  IssueDetailsNamedRefDto? publisher,  IssueDetailsNamedRefDto? imprint,  IssueDetailsSeriesDto? series,  String number, @JsonKey(name: 'alt_number')  String? altNumber,  String? title, @JsonKey(name: 'name')  List<String> names, @JsonKey(name: 'cover_date')  String? coverDate, @JsonKey(name: 'store_date')  String? storeDate, @JsonKey(name: 'foc_date')  String? focDate,  String? price, @JsonKey(name: 'price_currency')  String? priceCurrency,  IssueDetailsNamedRefDto? rating,  String? sku,  String? isbn,  String? upc, @JsonKey(name: 'page')  int? page, @JsonKey(name: 'desc')  String? description,  String? image, @JsonKey(name: 'cover_hash')  String? coverHash, @JsonKey(name: 'arcs')  List<IssueDetailsParticipationDto> arcs, @JsonKey(name: 'credits')  List<IssueDetailsCreditDto> credits, @JsonKey(name: 'characters')  List<IssueDetailsParticipationDto> characters, @JsonKey(name: 'teams')  List<IssueDetailsParticipationDto> teams, @JsonKey(name: 'universes')  List<IssueDetailsParticipationDto> universes, @JsonKey(name: 'reprints')  List<IssueDetailsReprintDto> reprints, @JsonKey(name: 'variants')  List<IssueDetailsVariantDto> variants, @JsonKey(name: 'cv_id')  int? cvId, @JsonKey(name: 'gcd_id')  int? gcdId, @JsonKey(name: 'resource_url')  String? resourceUrl,  String? modified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  IssueDetailsNamedRefDto? publisher,  IssueDetailsNamedRefDto? imprint,  IssueDetailsSeriesDto? series,  String number, @JsonKey(name: 'alt_number')  String? altNumber,  String? title, @JsonKey(name: 'name')  List<String> names, @JsonKey(name: 'cover_date')  String? coverDate, @JsonKey(name: 'store_date')  String? storeDate, @JsonKey(name: 'foc_date')  String? focDate,  String? price, @JsonKey(name: 'price_currency')  String? priceCurrency,  IssueDetailsNamedRefDto? rating,  String? sku,  String? isbn,  String? upc, @JsonKey(name: 'page')  int? page, @JsonKey(name: 'desc')  String? description,  String? image, @JsonKey(name: 'cover_hash')  String? coverHash, @JsonKey(name: 'arcs')  List<IssueDetailsParticipationDto> arcs, @JsonKey(name: 'credits')  List<IssueDetailsCreditDto> credits, @JsonKey(name: 'characters')  List<IssueDetailsParticipationDto> characters, @JsonKey(name: 'teams')  List<IssueDetailsParticipationDto> teams, @JsonKey(name: 'universes')  List<IssueDetailsParticipationDto> universes, @JsonKey(name: 'reprints')  List<IssueDetailsReprintDto> reprints, @JsonKey(name: 'variants')  List<IssueDetailsVariantDto> variants, @JsonKey(name: 'cv_id')  int? cvId, @JsonKey(name: 'gcd_id')  int? gcdId, @JsonKey(name: 'resource_url')  String? resourceUrl,  String? modified)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  IssueDetailsNamedRefDto? publisher,  IssueDetailsNamedRefDto? imprint,  IssueDetailsSeriesDto? series,  String number, @JsonKey(name: 'alt_number')  String? altNumber,  String? title, @JsonKey(name: 'name')  List<String> names, @JsonKey(name: 'cover_date')  String? coverDate, @JsonKey(name: 'store_date')  String? storeDate, @JsonKey(name: 'foc_date')  String? focDate,  String? price, @JsonKey(name: 'price_currency')  String? priceCurrency,  IssueDetailsNamedRefDto? rating,  String? sku,  String? isbn,  String? upc, @JsonKey(name: 'page')  int? page, @JsonKey(name: 'desc')  String? description,  String? image, @JsonKey(name: 'cover_hash')  String? coverHash, @JsonKey(name: 'arcs')  List<IssueDetailsParticipationDto> arcs, @JsonKey(name: 'credits')  List<IssueDetailsCreditDto> credits, @JsonKey(name: 'characters')  List<IssueDetailsParticipationDto> characters, @JsonKey(name: 'teams')  List<IssueDetailsParticipationDto> teams, @JsonKey(name: 'universes')  List<IssueDetailsParticipationDto> universes, @JsonKey(name: 'reprints')  List<IssueDetailsReprintDto> reprints, @JsonKey(name: 'variants')  List<IssueDetailsVariantDto> variants, @JsonKey(name: 'cv_id')  int? cvId, @JsonKey(name: 'gcd_id')  int? gcdId, @JsonKey(name: 'resource_url')  String? resourceUrl,  String? modified)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsDto() when $default != null:
return $default(_that.id,_that.publisher,_that.imprint,_that.series,_that.number,_that.altNumber,_that.title,_that.names,_that.coverDate,_that.storeDate,_that.focDate,_that.price,_that.priceCurrency,_that.rating,_that.sku,_that.isbn,_that.upc,_that.page,_that.description,_that.image,_that.coverHash,_that.arcs,_that.credits,_that.characters,_that.teams,_that.universes,_that.reprints,_that.variants,_that.cvId,_that.gcdId,_that.resourceUrl,_that.modified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDetailsDto extends IssueDetailsDto {
  const _IssueDetailsDto({required this.id, this.publisher, this.imprint, this.series, required this.number, @JsonKey(name: 'alt_number') this.altNumber, this.title, @JsonKey(name: 'name') final  List<String> names = const <String>[], @JsonKey(name: 'cover_date') this.coverDate, @JsonKey(name: 'store_date') this.storeDate, @JsonKey(name: 'foc_date') this.focDate, this.price, @JsonKey(name: 'price_currency') this.priceCurrency, this.rating, this.sku, this.isbn, this.upc, @JsonKey(name: 'page') this.page, @JsonKey(name: 'desc') this.description, this.image, @JsonKey(name: 'cover_hash') this.coverHash, @JsonKey(name: 'arcs') final  List<IssueDetailsParticipationDto> arcs = const <IssueDetailsParticipationDto>[], @JsonKey(name: 'credits') final  List<IssueDetailsCreditDto> credits = const <IssueDetailsCreditDto>[], @JsonKey(name: 'characters') final  List<IssueDetailsParticipationDto> characters = const <IssueDetailsParticipationDto>[], @JsonKey(name: 'teams') final  List<IssueDetailsParticipationDto> teams = const <IssueDetailsParticipationDto>[], @JsonKey(name: 'universes') final  List<IssueDetailsParticipationDto> universes = const <IssueDetailsParticipationDto>[], @JsonKey(name: 'reprints') final  List<IssueDetailsReprintDto> reprints = const <IssueDetailsReprintDto>[], @JsonKey(name: 'variants') final  List<IssueDetailsVariantDto> variants = const <IssueDetailsVariantDto>[], @JsonKey(name: 'cv_id') this.cvId, @JsonKey(name: 'gcd_id') this.gcdId, @JsonKey(name: 'resource_url') this.resourceUrl, this.modified}): _names = names,_arcs = arcs,_credits = credits,_characters = characters,_teams = teams,_universes = universes,_reprints = reprints,_variants = variants,super._();
  factory _IssueDetailsDto.fromJson(Map<String, dynamic> json) => _$IssueDetailsDtoFromJson(json);

@override final  int id;
@override final  IssueDetailsNamedRefDto? publisher;
@override final  IssueDetailsNamedRefDto? imprint;
@override final  IssueDetailsSeriesDto? series;
@override final  String number;
@override@JsonKey(name: 'alt_number') final  String? altNumber;
@override final  String? title;
 final  List<String> _names;
@override@JsonKey(name: 'name') List<String> get names {
  if (_names is EqualUnmodifiableListView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_names);
}

@override@JsonKey(name: 'cover_date') final  String? coverDate;
@override@JsonKey(name: 'store_date') final  String? storeDate;
@override@JsonKey(name: 'foc_date') final  String? focDate;
@override final  String? price;
@override@JsonKey(name: 'price_currency') final  String? priceCurrency;
@override final  IssueDetailsNamedRefDto? rating;
@override final  String? sku;
@override final  String? isbn;
@override final  String? upc;
@override@JsonKey(name: 'page') final  int? page;
@override@JsonKey(name: 'desc') final  String? description;
@override final  String? image;
@override@JsonKey(name: 'cover_hash') final  String? coverHash;
 final  List<IssueDetailsParticipationDto> _arcs;
@override@JsonKey(name: 'arcs') List<IssueDetailsParticipationDto> get arcs {
  if (_arcs is EqualUnmodifiableListView) return _arcs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_arcs);
}

 final  List<IssueDetailsCreditDto> _credits;
@override@JsonKey(name: 'credits') List<IssueDetailsCreditDto> get credits {
  if (_credits is EqualUnmodifiableListView) return _credits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_credits);
}

 final  List<IssueDetailsParticipationDto> _characters;
@override@JsonKey(name: 'characters') List<IssueDetailsParticipationDto> get characters {
  if (_characters is EqualUnmodifiableListView) return _characters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_characters);
}

 final  List<IssueDetailsParticipationDto> _teams;
@override@JsonKey(name: 'teams') List<IssueDetailsParticipationDto> get teams {
  if (_teams is EqualUnmodifiableListView) return _teams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teams);
}

 final  List<IssueDetailsParticipationDto> _universes;
@override@JsonKey(name: 'universes') List<IssueDetailsParticipationDto> get universes {
  if (_universes is EqualUnmodifiableListView) return _universes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_universes);
}

 final  List<IssueDetailsReprintDto> _reprints;
@override@JsonKey(name: 'reprints') List<IssueDetailsReprintDto> get reprints {
  if (_reprints is EqualUnmodifiableListView) return _reprints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reprints);
}

 final  List<IssueDetailsVariantDto> _variants;
@override@JsonKey(name: 'variants') List<IssueDetailsVariantDto> get variants {
  if (_variants is EqualUnmodifiableListView) return _variants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_variants);
}

@override@JsonKey(name: 'cv_id') final  int? cvId;
@override@JsonKey(name: 'gcd_id') final  int? gcdId;
@override@JsonKey(name: 'resource_url') final  String? resourceUrl;
@override final  String? modified;

/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsDtoCopyWith<_IssueDetailsDto> get copyWith => __$IssueDetailsDtoCopyWithImpl<_IssueDetailsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDetailsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsDto&&(identical(other.id, id) || other.id == id)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.imprint, imprint) || other.imprint == imprint)&&(identical(other.series, series) || other.series == series)&&(identical(other.number, number) || other.number == number)&&(identical(other.altNumber, altNumber) || other.altNumber == altNumber)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._names, _names)&&(identical(other.coverDate, coverDate) || other.coverDate == coverDate)&&(identical(other.storeDate, storeDate) || other.storeDate == storeDate)&&(identical(other.focDate, focDate) || other.focDate == focDate)&&(identical(other.price, price) || other.price == price)&&(identical(other.priceCurrency, priceCurrency) || other.priceCurrency == priceCurrency)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.upc, upc) || other.upc == upc)&&(identical(other.page, page) || other.page == page)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.coverHash, coverHash) || other.coverHash == coverHash)&&const DeepCollectionEquality().equals(other._arcs, _arcs)&&const DeepCollectionEquality().equals(other._credits, _credits)&&const DeepCollectionEquality().equals(other._characters, _characters)&&const DeepCollectionEquality().equals(other._teams, _teams)&&const DeepCollectionEquality().equals(other._universes, _universes)&&const DeepCollectionEquality().equals(other._reprints, _reprints)&&const DeepCollectionEquality().equals(other._variants, _variants)&&(identical(other.cvId, cvId) || other.cvId == cvId)&&(identical(other.gcdId, gcdId) || other.gcdId == gcdId)&&(identical(other.resourceUrl, resourceUrl) || other.resourceUrl == resourceUrl)&&(identical(other.modified, modified) || other.modified == modified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,publisher,imprint,series,number,altNumber,title,const DeepCollectionEquality().hash(_names),coverDate,storeDate,focDate,price,priceCurrency,rating,sku,isbn,upc,page,description,image,coverHash,const DeepCollectionEquality().hash(_arcs),const DeepCollectionEquality().hash(_credits),const DeepCollectionEquality().hash(_characters),const DeepCollectionEquality().hash(_teams),const DeepCollectionEquality().hash(_universes),const DeepCollectionEquality().hash(_reprints),const DeepCollectionEquality().hash(_variants),cvId,gcdId,resourceUrl,modified]);

@override
String toString() {
  return 'IssueDetailsDto(id: $id, publisher: $publisher, imprint: $imprint, series: $series, number: $number, altNumber: $altNumber, title: $title, names: $names, coverDate: $coverDate, storeDate: $storeDate, focDate: $focDate, price: $price, priceCurrency: $priceCurrency, rating: $rating, sku: $sku, isbn: $isbn, upc: $upc, page: $page, description: $description, image: $image, coverHash: $coverHash, arcs: $arcs, credits: $credits, characters: $characters, teams: $teams, universes: $universes, reprints: $reprints, variants: $variants, cvId: $cvId, gcdId: $gcdId, resourceUrl: $resourceUrl, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsDtoCopyWith<$Res> implements $IssueDetailsDtoCopyWith<$Res> {
  factory _$IssueDetailsDtoCopyWith(_IssueDetailsDto value, $Res Function(_IssueDetailsDto) _then) = __$IssueDetailsDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, IssueDetailsNamedRefDto? publisher, IssueDetailsNamedRefDto? imprint, IssueDetailsSeriesDto? series, String number,@JsonKey(name: 'alt_number') String? altNumber, String? title,@JsonKey(name: 'name') List<String> names,@JsonKey(name: 'cover_date') String? coverDate,@JsonKey(name: 'store_date') String? storeDate,@JsonKey(name: 'foc_date') String? focDate, String? price,@JsonKey(name: 'price_currency') String? priceCurrency, IssueDetailsNamedRefDto? rating, String? sku, String? isbn, String? upc,@JsonKey(name: 'page') int? page,@JsonKey(name: 'desc') String? description, String? image,@JsonKey(name: 'cover_hash') String? coverHash,@JsonKey(name: 'arcs') List<IssueDetailsParticipationDto> arcs,@JsonKey(name: 'credits') List<IssueDetailsCreditDto> credits,@JsonKey(name: 'characters') List<IssueDetailsParticipationDto> characters,@JsonKey(name: 'teams') List<IssueDetailsParticipationDto> teams,@JsonKey(name: 'universes') List<IssueDetailsParticipationDto> universes,@JsonKey(name: 'reprints') List<IssueDetailsReprintDto> reprints,@JsonKey(name: 'variants') List<IssueDetailsVariantDto> variants,@JsonKey(name: 'cv_id') int? cvId,@JsonKey(name: 'gcd_id') int? gcdId,@JsonKey(name: 'resource_url') String? resourceUrl, String? modified
});


@override $IssueDetailsNamedRefDtoCopyWith<$Res>? get publisher;@override $IssueDetailsNamedRefDtoCopyWith<$Res>? get imprint;@override $IssueDetailsSeriesDtoCopyWith<$Res>? get series;@override $IssueDetailsNamedRefDtoCopyWith<$Res>? get rating;

}
/// @nodoc
class __$IssueDetailsDtoCopyWithImpl<$Res>
    implements _$IssueDetailsDtoCopyWith<$Res> {
  __$IssueDetailsDtoCopyWithImpl(this._self, this._then);

  final _IssueDetailsDto _self;
  final $Res Function(_IssueDetailsDto) _then;

/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publisher = freezed,Object? imprint = freezed,Object? series = freezed,Object? number = null,Object? altNumber = freezed,Object? title = freezed,Object? names = null,Object? coverDate = freezed,Object? storeDate = freezed,Object? focDate = freezed,Object? price = freezed,Object? priceCurrency = freezed,Object? rating = freezed,Object? sku = freezed,Object? isbn = freezed,Object? upc = freezed,Object? page = freezed,Object? description = freezed,Object? image = freezed,Object? coverHash = freezed,Object? arcs = null,Object? credits = null,Object? characters = null,Object? teams = null,Object? universes = null,Object? reprints = null,Object? variants = null,Object? cvId = freezed,Object? gcdId = freezed,Object? resourceUrl = freezed,Object? modified = freezed,}) {
  return _then(_IssueDetailsDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRefDto?,imprint: freezed == imprint ? _self.imprint : imprint // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRefDto?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as IssueDetailsSeriesDto?,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,altNumber: freezed == altNumber ? _self.altNumber : altNumber // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,names: null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as List<String>,coverDate: freezed == coverDate ? _self.coverDate : coverDate // ignore: cast_nullable_to_non_nullable
as String?,storeDate: freezed == storeDate ? _self.storeDate : storeDate // ignore: cast_nullable_to_non_nullable
as String?,focDate: freezed == focDate ? _self.focDate : focDate // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,priceCurrency: freezed == priceCurrency ? _self.priceCurrency : priceCurrency // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRefDto?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,upc: freezed == upc ? _self.upc : upc // ignore: cast_nullable_to_non_nullable
as String?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,coverHash: freezed == coverHash ? _self.coverHash : coverHash // ignore: cast_nullable_to_non_nullable
as String?,arcs: null == arcs ? _self._arcs : arcs // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipationDto>,credits: null == credits ? _self._credits : credits // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsCreditDto>,characters: null == characters ? _self._characters : characters // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipationDto>,teams: null == teams ? _self._teams : teams // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipationDto>,universes: null == universes ? _self._universes : universes // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsParticipationDto>,reprints: null == reprints ? _self._reprints : reprints // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsReprintDto>,variants: null == variants ? _self._variants : variants // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsVariantDto>,cvId: freezed == cvId ? _self.cvId : cvId // ignore: cast_nullable_to_non_nullable
as int?,gcdId: freezed == gcdId ? _self.gcdId : gcdId // ignore: cast_nullable_to_non_nullable
as int?,resourceUrl: freezed == resourceUrl ? _self.resourceUrl : resourceUrl // ignore: cast_nullable_to_non_nullable
as String?,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $IssueDetailsNamedRefDtoCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<$Res>? get imprint {
    if (_self.imprint == null) {
    return null;
  }

  return $IssueDetailsNamedRefDtoCopyWith<$Res>(_self.imprint!, (value) {
    return _then(_self.copyWith(imprint: value));
  });
}/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsSeriesDtoCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $IssueDetailsSeriesDtoCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of IssueDetailsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $IssueDetailsNamedRefDtoCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// @nodoc
mixin _$IssueDetailsNamedRefDto {

 int get id; String get name;
/// Create a copy of IssueDetailsNamedRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<IssueDetailsNamedRefDto> get copyWith => _$IssueDetailsNamedRefDtoCopyWithImpl<IssueDetailsNamedRefDto>(this as IssueDetailsNamedRefDto, _$identity);

  /// Serializes this IssueDetailsNamedRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsNamedRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IssueDetailsNamedRefDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsNamedRefDtoCopyWith<$Res>  {
  factory $IssueDetailsNamedRefDtoCopyWith(IssueDetailsNamedRefDto value, $Res Function(IssueDetailsNamedRefDto) _then) = _$IssueDetailsNamedRefDtoCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$IssueDetailsNamedRefDtoCopyWithImpl<$Res>
    implements $IssueDetailsNamedRefDtoCopyWith<$Res> {
  _$IssueDetailsNamedRefDtoCopyWithImpl(this._self, this._then);

  final IssueDetailsNamedRefDto _self;
  final $Res Function(IssueDetailsNamedRefDto) _then;

/// Create a copy of IssueDetailsNamedRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsNamedRefDto].
extension IssueDetailsNamedRefDtoPatterns on IssueDetailsNamedRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsNamedRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsNamedRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsNamedRefDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsNamedRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsNamedRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsNamedRefDto() when $default != null:
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
case _IssueDetailsNamedRefDto() when $default != null:
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
case _IssueDetailsNamedRefDto():
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
case _IssueDetailsNamedRefDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDetailsNamedRefDto extends IssueDetailsNamedRefDto {
  const _IssueDetailsNamedRefDto({required this.id, required this.name}): super._();
  factory _IssueDetailsNamedRefDto.fromJson(Map<String, dynamic> json) => _$IssueDetailsNamedRefDtoFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of IssueDetailsNamedRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsNamedRefDtoCopyWith<_IssueDetailsNamedRefDto> get copyWith => __$IssueDetailsNamedRefDtoCopyWithImpl<_IssueDetailsNamedRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDetailsNamedRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsNamedRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IssueDetailsNamedRefDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsNamedRefDtoCopyWith<$Res> implements $IssueDetailsNamedRefDtoCopyWith<$Res> {
  factory _$IssueDetailsNamedRefDtoCopyWith(_IssueDetailsNamedRefDto value, $Res Function(_IssueDetailsNamedRefDto) _then) = __$IssueDetailsNamedRefDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$IssueDetailsNamedRefDtoCopyWithImpl<$Res>
    implements _$IssueDetailsNamedRefDtoCopyWith<$Res> {
  __$IssueDetailsNamedRefDtoCopyWithImpl(this._self, this._then);

  final _IssueDetailsNamedRefDto _self;
  final $Res Function(_IssueDetailsNamedRefDto) _then;

/// Create a copy of IssueDetailsNamedRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_IssueDetailsNamedRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$IssueDetailsSeriesDto {

 int get id; String get name;@JsonKey(name: 'sort_name') String? get sortName; int? get volume;@JsonKey(name: 'year_began') int? get yearBegan;@JsonKey(name: 'series_type') IssueDetailsNamedRefDto? get seriesType; List<IssueDetailsNamedRefDto> get genres;
/// Create a copy of IssueDetailsSeriesDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsSeriesDtoCopyWith<IssueDetailsSeriesDto> get copyWith => _$IssueDetailsSeriesDtoCopyWithImpl<IssueDetailsSeriesDto>(this as IssueDetailsSeriesDto, _$identity);

  /// Serializes this IssueDetailsSeriesDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsSeriesDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortName, sortName) || other.sortName == sortName)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.seriesType, seriesType) || other.seriesType == seriesType)&&const DeepCollectionEquality().equals(other.genres, genres));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sortName,volume,yearBegan,seriesType,const DeepCollectionEquality().hash(genres));

@override
String toString() {
  return 'IssueDetailsSeriesDto(id: $id, name: $name, sortName: $sortName, volume: $volume, yearBegan: $yearBegan, seriesType: $seriesType, genres: $genres)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsSeriesDtoCopyWith<$Res>  {
  factory $IssueDetailsSeriesDtoCopyWith(IssueDetailsSeriesDto value, $Res Function(IssueDetailsSeriesDto) _then) = _$IssueDetailsSeriesDtoCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'sort_name') String? sortName, int? volume,@JsonKey(name: 'year_began') int? yearBegan,@JsonKey(name: 'series_type') IssueDetailsNamedRefDto? seriesType, List<IssueDetailsNamedRefDto> genres
});


$IssueDetailsNamedRefDtoCopyWith<$Res>? get seriesType;

}
/// @nodoc
class _$IssueDetailsSeriesDtoCopyWithImpl<$Res>
    implements $IssueDetailsSeriesDtoCopyWith<$Res> {
  _$IssueDetailsSeriesDtoCopyWithImpl(this._self, this._then);

  final IssueDetailsSeriesDto _self;
  final $Res Function(IssueDetailsSeriesDto) _then;

/// Create a copy of IssueDetailsSeriesDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sortName = freezed,Object? volume = freezed,Object? yearBegan = freezed,Object? seriesType = freezed,Object? genres = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortName: freezed == sortName ? _self.sortName : sortName // ignore: cast_nullable_to_non_nullable
as String?,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int?,yearBegan: freezed == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int?,seriesType: freezed == seriesType ? _self.seriesType : seriesType // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRefDto?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsNamedRefDto>,
  ));
}
/// Create a copy of IssueDetailsSeriesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<$Res>? get seriesType {
    if (_self.seriesType == null) {
    return null;
  }

  return $IssueDetailsNamedRefDtoCopyWith<$Res>(_self.seriesType!, (value) {
    return _then(_self.copyWith(seriesType: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueDetailsSeriesDto].
extension IssueDetailsSeriesDtoPatterns on IssueDetailsSeriesDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsSeriesDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsSeriesDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsSeriesDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsSeriesDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsSeriesDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsSeriesDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'sort_name')  String? sortName,  int? volume, @JsonKey(name: 'year_began')  int? yearBegan, @JsonKey(name: 'series_type')  IssueDetailsNamedRefDto? seriesType,  List<IssueDetailsNamedRefDto> genres)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsSeriesDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'sort_name')  String? sortName,  int? volume, @JsonKey(name: 'year_began')  int? yearBegan, @JsonKey(name: 'series_type')  IssueDetailsNamedRefDto? seriesType,  List<IssueDetailsNamedRefDto> genres)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsSeriesDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'sort_name')  String? sortName,  int? volume, @JsonKey(name: 'year_began')  int? yearBegan, @JsonKey(name: 'series_type')  IssueDetailsNamedRefDto? seriesType,  List<IssueDetailsNamedRefDto> genres)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsSeriesDto() when $default != null:
return $default(_that.id,_that.name,_that.sortName,_that.volume,_that.yearBegan,_that.seriesType,_that.genres);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDetailsSeriesDto extends IssueDetailsSeriesDto {
  const _IssueDetailsSeriesDto({required this.id, required this.name, @JsonKey(name: 'sort_name') this.sortName, this.volume, @JsonKey(name: 'year_began') this.yearBegan, @JsonKey(name: 'series_type') this.seriesType, final  List<IssueDetailsNamedRefDto> genres = const <IssueDetailsNamedRefDto>[]}): _genres = genres,super._();
  factory _IssueDetailsSeriesDto.fromJson(Map<String, dynamic> json) => _$IssueDetailsSeriesDtoFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'sort_name') final  String? sortName;
@override final  int? volume;
@override@JsonKey(name: 'year_began') final  int? yearBegan;
@override@JsonKey(name: 'series_type') final  IssueDetailsNamedRefDto? seriesType;
 final  List<IssueDetailsNamedRefDto> _genres;
@override@JsonKey() List<IssueDetailsNamedRefDto> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}


/// Create a copy of IssueDetailsSeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsSeriesDtoCopyWith<_IssueDetailsSeriesDto> get copyWith => __$IssueDetailsSeriesDtoCopyWithImpl<_IssueDetailsSeriesDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDetailsSeriesDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsSeriesDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortName, sortName) || other.sortName == sortName)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.yearBegan, yearBegan) || other.yearBegan == yearBegan)&&(identical(other.seriesType, seriesType) || other.seriesType == seriesType)&&const DeepCollectionEquality().equals(other._genres, _genres));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sortName,volume,yearBegan,seriesType,const DeepCollectionEquality().hash(_genres));

@override
String toString() {
  return 'IssueDetailsSeriesDto(id: $id, name: $name, sortName: $sortName, volume: $volume, yearBegan: $yearBegan, seriesType: $seriesType, genres: $genres)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsSeriesDtoCopyWith<$Res> implements $IssueDetailsSeriesDtoCopyWith<$Res> {
  factory _$IssueDetailsSeriesDtoCopyWith(_IssueDetailsSeriesDto value, $Res Function(_IssueDetailsSeriesDto) _then) = __$IssueDetailsSeriesDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'sort_name') String? sortName, int? volume,@JsonKey(name: 'year_began') int? yearBegan,@JsonKey(name: 'series_type') IssueDetailsNamedRefDto? seriesType, List<IssueDetailsNamedRefDto> genres
});


@override $IssueDetailsNamedRefDtoCopyWith<$Res>? get seriesType;

}
/// @nodoc
class __$IssueDetailsSeriesDtoCopyWithImpl<$Res>
    implements _$IssueDetailsSeriesDtoCopyWith<$Res> {
  __$IssueDetailsSeriesDtoCopyWithImpl(this._self, this._then);

  final _IssueDetailsSeriesDto _self;
  final $Res Function(_IssueDetailsSeriesDto) _then;

/// Create a copy of IssueDetailsSeriesDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sortName = freezed,Object? volume = freezed,Object? yearBegan = freezed,Object? seriesType = freezed,Object? genres = null,}) {
  return _then(_IssueDetailsSeriesDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortName: freezed == sortName ? _self.sortName : sortName // ignore: cast_nullable_to_non_nullable
as String?,volume: freezed == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as int?,yearBegan: freezed == yearBegan ? _self.yearBegan : yearBegan // ignore: cast_nullable_to_non_nullable
as int?,seriesType: freezed == seriesType ? _self.seriesType : seriesType // ignore: cast_nullable_to_non_nullable
as IssueDetailsNamedRefDto?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsNamedRefDto>,
  ));
}

/// Create a copy of IssueDetailsSeriesDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IssueDetailsNamedRefDtoCopyWith<$Res>? get seriesType {
    if (_self.seriesType == null) {
    return null;
  }

  return $IssueDetailsNamedRefDtoCopyWith<$Res>(_self.seriesType!, (value) {
    return _then(_self.copyWith(seriesType: value));
  });
}
}


/// @nodoc
mixin _$IssueDetailsParticipationDto {

 int get id; String get name; String? get modified;
/// Create a copy of IssueDetailsParticipationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsParticipationDtoCopyWith<IssueDetailsParticipationDto> get copyWith => _$IssueDetailsParticipationDtoCopyWithImpl<IssueDetailsParticipationDto>(this as IssueDetailsParticipationDto, _$identity);

  /// Serializes this IssueDetailsParticipationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsParticipationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.modified, modified) || other.modified == modified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,modified);

@override
String toString() {
  return 'IssueDetailsParticipationDto(id: $id, name: $name, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsParticipationDtoCopyWith<$Res>  {
  factory $IssueDetailsParticipationDtoCopyWith(IssueDetailsParticipationDto value, $Res Function(IssueDetailsParticipationDto) _then) = _$IssueDetailsParticipationDtoCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? modified
});




}
/// @nodoc
class _$IssueDetailsParticipationDtoCopyWithImpl<$Res>
    implements $IssueDetailsParticipationDtoCopyWith<$Res> {
  _$IssueDetailsParticipationDtoCopyWithImpl(this._self, this._then);

  final IssueDetailsParticipationDto _self;
  final $Res Function(IssueDetailsParticipationDto) _then;

/// Create a copy of IssueDetailsParticipationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? modified = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsParticipationDto].
extension IssueDetailsParticipationDtoPatterns on IssueDetailsParticipationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsParticipationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsParticipationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsParticipationDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsParticipationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsParticipationDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsParticipationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? modified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsParticipationDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? modified)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsParticipationDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? modified)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsParticipationDto() when $default != null:
return $default(_that.id,_that.name,_that.modified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDetailsParticipationDto extends IssueDetailsParticipationDto {
  const _IssueDetailsParticipationDto({required this.id, required this.name, this.modified}): super._();
  factory _IssueDetailsParticipationDto.fromJson(Map<String, dynamic> json) => _$IssueDetailsParticipationDtoFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? modified;

/// Create a copy of IssueDetailsParticipationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsParticipationDtoCopyWith<_IssueDetailsParticipationDto> get copyWith => __$IssueDetailsParticipationDtoCopyWithImpl<_IssueDetailsParticipationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDetailsParticipationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsParticipationDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.modified, modified) || other.modified == modified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,modified);

@override
String toString() {
  return 'IssueDetailsParticipationDto(id: $id, name: $name, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsParticipationDtoCopyWith<$Res> implements $IssueDetailsParticipationDtoCopyWith<$Res> {
  factory _$IssueDetailsParticipationDtoCopyWith(_IssueDetailsParticipationDto value, $Res Function(_IssueDetailsParticipationDto) _then) = __$IssueDetailsParticipationDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? modified
});




}
/// @nodoc
class __$IssueDetailsParticipationDtoCopyWithImpl<$Res>
    implements _$IssueDetailsParticipationDtoCopyWith<$Res> {
  __$IssueDetailsParticipationDtoCopyWithImpl(this._self, this._then);

  final _IssueDetailsParticipationDto _self;
  final $Res Function(_IssueDetailsParticipationDto) _then;

/// Create a copy of IssueDetailsParticipationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? modified = freezed,}) {
  return _then(_IssueDetailsParticipationDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,modified: freezed == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$IssueDetailsCreditRoleDto {

 int get id; String get name;
/// Create a copy of IssueDetailsCreditRoleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsCreditRoleDtoCopyWith<IssueDetailsCreditRoleDto> get copyWith => _$IssueDetailsCreditRoleDtoCopyWithImpl<IssueDetailsCreditRoleDto>(this as IssueDetailsCreditRoleDto, _$identity);

  /// Serializes this IssueDetailsCreditRoleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsCreditRoleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IssueDetailsCreditRoleDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsCreditRoleDtoCopyWith<$Res>  {
  factory $IssueDetailsCreditRoleDtoCopyWith(IssueDetailsCreditRoleDto value, $Res Function(IssueDetailsCreditRoleDto) _then) = _$IssueDetailsCreditRoleDtoCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$IssueDetailsCreditRoleDtoCopyWithImpl<$Res>
    implements $IssueDetailsCreditRoleDtoCopyWith<$Res> {
  _$IssueDetailsCreditRoleDtoCopyWithImpl(this._self, this._then);

  final IssueDetailsCreditRoleDto _self;
  final $Res Function(IssueDetailsCreditRoleDto) _then;

/// Create a copy of IssueDetailsCreditRoleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsCreditRoleDto].
extension IssueDetailsCreditRoleDtoPatterns on IssueDetailsCreditRoleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsCreditRoleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsCreditRoleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsCreditRoleDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsCreditRoleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsCreditRoleDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsCreditRoleDto() when $default != null:
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
case _IssueDetailsCreditRoleDto() when $default != null:
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
case _IssueDetailsCreditRoleDto():
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
case _IssueDetailsCreditRoleDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDetailsCreditRoleDto extends IssueDetailsCreditRoleDto {
  const _IssueDetailsCreditRoleDto({required this.id, required this.name}): super._();
  factory _IssueDetailsCreditRoleDto.fromJson(Map<String, dynamic> json) => _$IssueDetailsCreditRoleDtoFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of IssueDetailsCreditRoleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsCreditRoleDtoCopyWith<_IssueDetailsCreditRoleDto> get copyWith => __$IssueDetailsCreditRoleDtoCopyWithImpl<_IssueDetailsCreditRoleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDetailsCreditRoleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsCreditRoleDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IssueDetailsCreditRoleDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsCreditRoleDtoCopyWith<$Res> implements $IssueDetailsCreditRoleDtoCopyWith<$Res> {
  factory _$IssueDetailsCreditRoleDtoCopyWith(_IssueDetailsCreditRoleDto value, $Res Function(_IssueDetailsCreditRoleDto) _then) = __$IssueDetailsCreditRoleDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$IssueDetailsCreditRoleDtoCopyWithImpl<$Res>
    implements _$IssueDetailsCreditRoleDtoCopyWith<$Res> {
  __$IssueDetailsCreditRoleDtoCopyWithImpl(this._self, this._then);

  final _IssueDetailsCreditRoleDto _self;
  final $Res Function(_IssueDetailsCreditRoleDto) _then;

/// Create a copy of IssueDetailsCreditRoleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_IssueDetailsCreditRoleDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$IssueDetailsCreditDto {

 int get id; String? get creator;@JsonKey(name: 'role') List<IssueDetailsCreditRoleDto> get roles;@JsonKey(name: 'creator_id') int? get creatorId;
/// Create a copy of IssueDetailsCreditDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsCreditDtoCopyWith<IssueDetailsCreditDto> get copyWith => _$IssueDetailsCreditDtoCopyWithImpl<IssueDetailsCreditDto>(this as IssueDetailsCreditDto, _$identity);

  /// Serializes this IssueDetailsCreditDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsCreditDto&&(identical(other.id, id) || other.id == id)&&(identical(other.creator, creator) || other.creator == creator)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creator,const DeepCollectionEquality().hash(roles),creatorId);

@override
String toString() {
  return 'IssueDetailsCreditDto(id: $id, creator: $creator, roles: $roles, creatorId: $creatorId)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsCreditDtoCopyWith<$Res>  {
  factory $IssueDetailsCreditDtoCopyWith(IssueDetailsCreditDto value, $Res Function(IssueDetailsCreditDto) _then) = _$IssueDetailsCreditDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? creator,@JsonKey(name: 'role') List<IssueDetailsCreditRoleDto> roles,@JsonKey(name: 'creator_id') int? creatorId
});




}
/// @nodoc
class _$IssueDetailsCreditDtoCopyWithImpl<$Res>
    implements $IssueDetailsCreditDtoCopyWith<$Res> {
  _$IssueDetailsCreditDtoCopyWithImpl(this._self, this._then);

  final IssueDetailsCreditDto _self;
  final $Res Function(IssueDetailsCreditDto) _then;

/// Create a copy of IssueDetailsCreditDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creator = freezed,Object? roles = null,Object? creatorId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsCreditRoleDto>,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsCreditDto].
extension IssueDetailsCreditDtoPatterns on IssueDetailsCreditDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsCreditDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsCreditDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsCreditDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsCreditDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsCreditDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsCreditDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? creator, @JsonKey(name: 'role')  List<IssueDetailsCreditRoleDto> roles, @JsonKey(name: 'creator_id')  int? creatorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueDetailsCreditDto() when $default != null:
return $default(_that.id,_that.creator,_that.roles,_that.creatorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? creator, @JsonKey(name: 'role')  List<IssueDetailsCreditRoleDto> roles, @JsonKey(name: 'creator_id')  int? creatorId)  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsCreditDto():
return $default(_that.id,_that.creator,_that.roles,_that.creatorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? creator, @JsonKey(name: 'role')  List<IssueDetailsCreditRoleDto> roles, @JsonKey(name: 'creator_id')  int? creatorId)?  $default,) {final _that = this;
switch (_that) {
case _IssueDetailsCreditDto() when $default != null:
return $default(_that.id,_that.creator,_that.roles,_that.creatorId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDetailsCreditDto extends IssueDetailsCreditDto {
  const _IssueDetailsCreditDto({required this.id, this.creator, @JsonKey(name: 'role') final  List<IssueDetailsCreditRoleDto> roles = const <IssueDetailsCreditRoleDto>[], @JsonKey(name: 'creator_id') this.creatorId}): _roles = roles,super._();
  factory _IssueDetailsCreditDto.fromJson(Map<String, dynamic> json) => _$IssueDetailsCreditDtoFromJson(json);

@override final  int id;
@override final  String? creator;
 final  List<IssueDetailsCreditRoleDto> _roles;
@override@JsonKey(name: 'role') List<IssueDetailsCreditRoleDto> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override@JsonKey(name: 'creator_id') final  int? creatorId;

/// Create a copy of IssueDetailsCreditDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsCreditDtoCopyWith<_IssueDetailsCreditDto> get copyWith => __$IssueDetailsCreditDtoCopyWithImpl<_IssueDetailsCreditDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDetailsCreditDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsCreditDto&&(identical(other.id, id) || other.id == id)&&(identical(other.creator, creator) || other.creator == creator)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creator,const DeepCollectionEquality().hash(_roles),creatorId);

@override
String toString() {
  return 'IssueDetailsCreditDto(id: $id, creator: $creator, roles: $roles, creatorId: $creatorId)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsCreditDtoCopyWith<$Res> implements $IssueDetailsCreditDtoCopyWith<$Res> {
  factory _$IssueDetailsCreditDtoCopyWith(_IssueDetailsCreditDto value, $Res Function(_IssueDetailsCreditDto) _then) = __$IssueDetailsCreditDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? creator,@JsonKey(name: 'role') List<IssueDetailsCreditRoleDto> roles,@JsonKey(name: 'creator_id') int? creatorId
});




}
/// @nodoc
class __$IssueDetailsCreditDtoCopyWithImpl<$Res>
    implements _$IssueDetailsCreditDtoCopyWith<$Res> {
  __$IssueDetailsCreditDtoCopyWithImpl(this._self, this._then);

  final _IssueDetailsCreditDto _self;
  final $Res Function(_IssueDetailsCreditDto) _then;

/// Create a copy of IssueDetailsCreditDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creator = freezed,Object? roles = null,Object? creatorId = freezed,}) {
  return _then(_IssueDetailsCreditDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<IssueDetailsCreditRoleDto>,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$IssueDetailsReprintDto {

 int get id; String? get issue;
/// Create a copy of IssueDetailsReprintDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsReprintDtoCopyWith<IssueDetailsReprintDto> get copyWith => _$IssueDetailsReprintDtoCopyWithImpl<IssueDetailsReprintDto>(this as IssueDetailsReprintDto, _$identity);

  /// Serializes this IssueDetailsReprintDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsReprintDto&&(identical(other.id, id) || other.id == id)&&(identical(other.issue, issue) || other.issue == issue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,issue);

@override
String toString() {
  return 'IssueDetailsReprintDto(id: $id, issue: $issue)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsReprintDtoCopyWith<$Res>  {
  factory $IssueDetailsReprintDtoCopyWith(IssueDetailsReprintDto value, $Res Function(IssueDetailsReprintDto) _then) = _$IssueDetailsReprintDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? issue
});




}
/// @nodoc
class _$IssueDetailsReprintDtoCopyWithImpl<$Res>
    implements $IssueDetailsReprintDtoCopyWith<$Res> {
  _$IssueDetailsReprintDtoCopyWithImpl(this._self, this._then);

  final IssueDetailsReprintDto _self;
  final $Res Function(IssueDetailsReprintDto) _then;

/// Create a copy of IssueDetailsReprintDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? issue = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,issue: freezed == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueDetailsReprintDto].
extension IssueDetailsReprintDtoPatterns on IssueDetailsReprintDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsReprintDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsReprintDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsReprintDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsReprintDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsReprintDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsReprintDto() when $default != null:
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
case _IssueDetailsReprintDto() when $default != null:
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
case _IssueDetailsReprintDto():
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
case _IssueDetailsReprintDto() when $default != null:
return $default(_that.id,_that.issue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDetailsReprintDto extends IssueDetailsReprintDto {
  const _IssueDetailsReprintDto({required this.id, this.issue}): super._();
  factory _IssueDetailsReprintDto.fromJson(Map<String, dynamic> json) => _$IssueDetailsReprintDtoFromJson(json);

@override final  int id;
@override final  String? issue;

/// Create a copy of IssueDetailsReprintDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsReprintDtoCopyWith<_IssueDetailsReprintDto> get copyWith => __$IssueDetailsReprintDtoCopyWithImpl<_IssueDetailsReprintDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDetailsReprintDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsReprintDto&&(identical(other.id, id) || other.id == id)&&(identical(other.issue, issue) || other.issue == issue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,issue);

@override
String toString() {
  return 'IssueDetailsReprintDto(id: $id, issue: $issue)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsReprintDtoCopyWith<$Res> implements $IssueDetailsReprintDtoCopyWith<$Res> {
  factory _$IssueDetailsReprintDtoCopyWith(_IssueDetailsReprintDto value, $Res Function(_IssueDetailsReprintDto) _then) = __$IssueDetailsReprintDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? issue
});




}
/// @nodoc
class __$IssueDetailsReprintDtoCopyWithImpl<$Res>
    implements _$IssueDetailsReprintDtoCopyWith<$Res> {
  __$IssueDetailsReprintDtoCopyWithImpl(this._self, this._then);

  final _IssueDetailsReprintDto _self;
  final $Res Function(_IssueDetailsReprintDto) _then;

/// Create a copy of IssueDetailsReprintDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? issue = freezed,}) {
  return _then(_IssueDetailsReprintDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,issue: freezed == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$IssueDetailsVariantDto {

 String? get name; String? get price; String? get sku; String? get upc; String? get image;
/// Create a copy of IssueDetailsVariantDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueDetailsVariantDtoCopyWith<IssueDetailsVariantDto> get copyWith => _$IssueDetailsVariantDtoCopyWithImpl<IssueDetailsVariantDto>(this as IssueDetailsVariantDto, _$identity);

  /// Serializes this IssueDetailsVariantDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueDetailsVariantDto&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.upc, upc) || other.upc == upc)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,sku,upc,image);

@override
String toString() {
  return 'IssueDetailsVariantDto(name: $name, price: $price, sku: $sku, upc: $upc, image: $image)';
}


}

/// @nodoc
abstract mixin class $IssueDetailsVariantDtoCopyWith<$Res>  {
  factory $IssueDetailsVariantDtoCopyWith(IssueDetailsVariantDto value, $Res Function(IssueDetailsVariantDto) _then) = _$IssueDetailsVariantDtoCopyWithImpl;
@useResult
$Res call({
 String? name, String? price, String? sku, String? upc, String? image
});




}
/// @nodoc
class _$IssueDetailsVariantDtoCopyWithImpl<$Res>
    implements $IssueDetailsVariantDtoCopyWith<$Res> {
  _$IssueDetailsVariantDtoCopyWithImpl(this._self, this._then);

  final IssueDetailsVariantDto _self;
  final $Res Function(IssueDetailsVariantDto) _then;

/// Create a copy of IssueDetailsVariantDto
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


/// Adds pattern-matching-related methods to [IssueDetailsVariantDto].
extension IssueDetailsVariantDtoPatterns on IssueDetailsVariantDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueDetailsVariantDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueDetailsVariantDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueDetailsVariantDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsVariantDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueDetailsVariantDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueDetailsVariantDto() when $default != null:
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
case _IssueDetailsVariantDto() when $default != null:
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
case _IssueDetailsVariantDto():
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
case _IssueDetailsVariantDto() when $default != null:
return $default(_that.name,_that.price,_that.sku,_that.upc,_that.image);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueDetailsVariantDto extends IssueDetailsVariantDto {
  const _IssueDetailsVariantDto({this.name, this.price, this.sku, this.upc, this.image}): super._();
  factory _IssueDetailsVariantDto.fromJson(Map<String, dynamic> json) => _$IssueDetailsVariantDtoFromJson(json);

@override final  String? name;
@override final  String? price;
@override final  String? sku;
@override final  String? upc;
@override final  String? image;

/// Create a copy of IssueDetailsVariantDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueDetailsVariantDtoCopyWith<_IssueDetailsVariantDto> get copyWith => __$IssueDetailsVariantDtoCopyWithImpl<_IssueDetailsVariantDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueDetailsVariantDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueDetailsVariantDto&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.upc, upc) || other.upc == upc)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,sku,upc,image);

@override
String toString() {
  return 'IssueDetailsVariantDto(name: $name, price: $price, sku: $sku, upc: $upc, image: $image)';
}


}

/// @nodoc
abstract mixin class _$IssueDetailsVariantDtoCopyWith<$Res> implements $IssueDetailsVariantDtoCopyWith<$Res> {
  factory _$IssueDetailsVariantDtoCopyWith(_IssueDetailsVariantDto value, $Res Function(_IssueDetailsVariantDto) _then) = __$IssueDetailsVariantDtoCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? price, String? sku, String? upc, String? image
});




}
/// @nodoc
class __$IssueDetailsVariantDtoCopyWithImpl<$Res>
    implements _$IssueDetailsVariantDtoCopyWith<$Res> {
  __$IssueDetailsVariantDtoCopyWithImpl(this._self, this._then);

  final _IssueDetailsVariantDto _self;
  final $Res Function(_IssueDetailsVariantDto) _then;

/// Create a copy of IssueDetailsVariantDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? price = freezed,Object? sku = freezed,Object? upc = freezed,Object? image = freezed,}) {
  return _then(_IssueDetailsVariantDto(
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
