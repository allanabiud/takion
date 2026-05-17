import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:takion/src/domain/entities/issue_details.dart';

part 'issue_details_dto.freezed.dart';
part 'issue_details_dto.g.dart';

@freezed
@HiveType(typeId: 10)
abstract class IssueDetailsDto with _$IssueDetailsDto {
  const factory IssueDetailsDto({
    @HiveField(0) required int id,
    @HiveField(1) IssueDetailsNamedRefDto? publisher,
    @HiveField(2) IssueDetailsNamedRefDto? imprint,
    @HiveField(3) IssueDetailsSeriesDto? series,
    @HiveField(4) required String number,
    @HiveField(5) @JsonKey(name: 'alt_number') String? altNumber,
    @HiveField(6) String? title,
    @HiveField(7) @JsonKey(name: 'name') @Default(<String>[]) List<String> names,
    @HiveField(8) @JsonKey(name: 'cover_date') String? coverDate,
    @HiveField(9) @JsonKey(name: 'store_date') String? storeDate,
    @HiveField(10) @JsonKey(name: 'foc_date') String? focDate,
    @HiveField(11) String? price,
    @HiveField(12) @JsonKey(name: 'price_currency') String? priceCurrency,
    @HiveField(13) IssueDetailsNamedRefDto? rating,
    @HiveField(14) String? sku,
    @HiveField(15) String? isbn,
    @HiveField(16) String? upc,
    @HiveField(17) @JsonKey(name: 'page') int? page,
    @HiveField(18) @JsonKey(name: 'desc') String? description,
    @HiveField(19) String? image,
    @HiveField(20) @JsonKey(name: 'cover_hash') String? coverHash,
    @HiveField(21)
    @JsonKey(name: 'arcs')
    @Default(<IssueDetailsParticipationDto>[])
    List<IssueDetailsParticipationDto> arcs,
    @HiveField(22)
    @JsonKey(name: 'credits')
    @Default(<IssueDetailsCreditDto>[])
    List<IssueDetailsCreditDto> credits,
    @HiveField(23)
    @JsonKey(name: 'characters')
    @Default(<IssueDetailsParticipationDto>[])
    List<IssueDetailsParticipationDto> characters,
    @HiveField(24)
    @JsonKey(name: 'teams')
    @Default(<IssueDetailsParticipationDto>[])
    List<IssueDetailsParticipationDto> teams,
    @HiveField(25)
    @JsonKey(name: 'universes')
    @Default(<IssueDetailsParticipationDto>[])
    List<IssueDetailsParticipationDto> universes,
    @HiveField(26)
    @JsonKey(name: 'reprints')
    @Default(<IssueDetailsReprintDto>[])
    List<IssueDetailsReprintDto> reprints,
    @HiveField(27)
    @JsonKey(name: 'variants')
    @Default(<IssueDetailsVariantDto>[])
    List<IssueDetailsVariantDto> variants,
    @HiveField(28) @JsonKey(name: 'cv_id') int? cvId,
    @HiveField(29) @JsonKey(name: 'gcd_id') int? gcdId,
    @HiveField(30) @JsonKey(name: 'resource_url') String? resourceUrl,
    @HiveField(31) String? modified,
  }) = _IssueDetailsDto;

  factory IssueDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsDtoFromJson(json);

  const IssueDetailsDto._();

  IssueDetails toEntity() {
    return IssueDetails(
      id: id,
      publisher: publisher?.toEntity(),
      imprint: imprint?.toEntity(),
      series: series?.toEntity(),
      number: number,
      altNumber: altNumber,
      title: title,
      names: names,
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      focDate: focDate != null ? DateTime.tryParse(focDate!) : null,
      price: price,
      priceCurrency: priceCurrency,
      rating: rating?.toEntity(),
      sku: sku,
      isbn: isbn,
      upc: upc,
      page: page,
      description: description,
      image: image,
      coverHash: coverHash,
      arcs: arcs.map((entry) => entry.toEntity()).toList(),
      credits: credits.map((entry) => entry.toEntity()).toList(),
      characters: characters.map((entry) => entry.toEntity()).toList(),
      teams: teams.map((entry) => entry.toEntity()).toList(),
      universes: universes.map((entry) => entry.toEntity()).toList(),
      reprints: reprints.map((entry) => entry.toEntity()).toList(),
      variants: variants.map((entry) => entry.toEntity()).toList(),
      cvId: cvId,
      gcdId: gcdId,
      resourceUrl: resourceUrl,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}

@freezed
@HiveType(typeId: 11)
abstract class IssueDetailsNamedRefDto with _$IssueDetailsNamedRefDto {
  const factory IssueDetailsNamedRefDto({
    @HiveField(0) required int id,
    @HiveField(1) required String name,
  }) = _IssueDetailsNamedRefDto;

  factory IssueDetailsNamedRefDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsNamedRefDtoFromJson(json);

  const IssueDetailsNamedRefDto._();

  IssueDetailsNamedRef toEntity() => IssueDetailsNamedRef(id: id, name: name);
}

@freezed
@HiveType(typeId: 12)
abstract class IssueDetailsSeriesDto with _$IssueDetailsSeriesDto {
  const factory IssueDetailsSeriesDto({
    @HiveField(0) required int id,
    @HiveField(1) required String name,
    @HiveField(2) @JsonKey(name: 'sort_name') String? sortName,
    @HiveField(3) int? volume,
    @HiveField(4) @JsonKey(name: 'year_began') int? yearBegan,
    @HiveField(5) @JsonKey(name: 'series_type') IssueDetailsNamedRefDto? seriesType,
    @HiveField(6) @Default(<IssueDetailsNamedRefDto>[]) List<IssueDetailsNamedRefDto> genres,
  }) = _IssueDetailsSeriesDto;

  factory IssueDetailsSeriesDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsSeriesDtoFromJson(json);

  const IssueDetailsSeriesDto._();

  IssueDetailsSeries toEntity() {
    return IssueDetailsSeries(
      id: id,
      name: name,
      sortName: sortName,
      volume: volume,
      yearBegan: yearBegan,
      seriesType: seriesType?.toEntity(),
      genres: genres.map((entry) => entry.toEntity()).toList(),
    );
  }
}

@freezed
@HiveType(typeId: 13)
abstract class IssueDetailsParticipationDto with _$IssueDetailsParticipationDto {
  const factory IssueDetailsParticipationDto({
    @HiveField(0) required int id,
    @HiveField(1) required String name,
    @HiveField(2) String? modified,
  }) = _IssueDetailsParticipationDto;

  factory IssueDetailsParticipationDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsParticipationDtoFromJson(json);

  const IssueDetailsParticipationDto._();

  IssueDetailsParticipation toEntity() {
    return IssueDetailsParticipation(
      id: id,
      name: name,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}

@freezed
@HiveType(typeId: 14)
abstract class IssueDetailsCreditRoleDto with _$IssueDetailsCreditRoleDto {
  const factory IssueDetailsCreditRoleDto({
    @HiveField(0) required int id,
    @HiveField(1) required String name,
  }) = _IssueDetailsCreditRoleDto;

  factory IssueDetailsCreditRoleDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsCreditRoleDtoFromJson(json);

  const IssueDetailsCreditRoleDto._();

  IssueDetailsCreditRole toEntity() {
    return IssueDetailsCreditRole(id: id, name: name);
  }
}

@freezed
@HiveType(typeId: 15)
abstract class IssueDetailsCreditDto with _$IssueDetailsCreditDto {
  const factory IssueDetailsCreditDto({
    @HiveField(0) required int id,
    @HiveField(1) String? creator,
    @HiveField(2)
    @JsonKey(name: 'role')
    @Default(<IssueDetailsCreditRoleDto>[])
    List<IssueDetailsCreditRoleDto> roles,
  }) = _IssueDetailsCreditDto;

  factory IssueDetailsCreditDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsCreditDtoFromJson(json);

  const IssueDetailsCreditDto._();

  IssueDetailsCredit toEntity() {
    return IssueDetailsCredit(
      id: id,
      creator: creator,
      roles: roles.map((entry) => entry.toEntity()).toList(),
    );
  }
}

@freezed
@HiveType(typeId: 16)
abstract class IssueDetailsReprintDto with _$IssueDetailsReprintDto {
  const factory IssueDetailsReprintDto({
    @HiveField(0) required int id,
    @HiveField(1) String? issue,
  }) = _IssueDetailsReprintDto;

  factory IssueDetailsReprintDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsReprintDtoFromJson(json);

  const IssueDetailsReprintDto._();

  IssueDetailsReprint toEntity() => IssueDetailsReprint(id: id, issue: issue);
}

@freezed
@HiveType(typeId: 17)
abstract class IssueDetailsVariantDto with _$IssueDetailsVariantDto {
  const factory IssueDetailsVariantDto({
    @HiveField(0) String? name,
    @HiveField(1) String? price,
    @HiveField(2) String? sku,
    @HiveField(3) String? upc,
    @HiveField(4) String? image,
  }) = _IssueDetailsVariantDto;

  factory IssueDetailsVariantDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsVariantDtoFromJson(json);

  const IssueDetailsVariantDto._();

  IssueDetailsVariant toEntity() {
    return IssueDetailsVariant(
      name: name,
      price: price,
      sku: sku,
      upc: upc,
      image: image,
    );
  }
}
