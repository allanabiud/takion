import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:takion/src/domain/entities.dart';

part 'issue_details_dto.freezed.dart';
part 'issue_details_dto.g.dart';

@freezed
abstract class IssueDetailsDto with _$IssueDetailsDto {
  const factory IssueDetailsDto({
    required int id,
    IssueDetailsNamedRefDto? publisher,
    IssueDetailsNamedRefDto? imprint,
    IssueDetailsSeriesDto? series,
    required String number,
    @JsonKey(name: 'alt_number') String? altNumber,
    String? title,
    @JsonKey(name: 'name') @Default(<String>[]) List<String> names,
    @JsonKey(name: 'cover_date') String? coverDate,
    @JsonKey(name: 'store_date') String? storeDate,
    @JsonKey(name: 'foc_date') String? focDate,
    String? price,
    @JsonKey(name: 'price_currency') String? priceCurrency,
    IssueDetailsNamedRefDto? rating,
    String? sku,
    String? isbn,
    String? upc,
    @JsonKey(name: 'page') int? page,
    @JsonKey(name: 'desc') String? description,
    String? image,
    @JsonKey(name: 'cover_hash') String? coverHash,
    @JsonKey(name: 'arcs')
    @Default(<IssueDetailsParticipationDto>[])
    List<IssueDetailsParticipationDto> arcs,
    @JsonKey(name: 'credits')
    @Default(<IssueDetailsCreditDto>[])
    List<IssueDetailsCreditDto> credits,
    @JsonKey(name: 'characters')
    @Default(<IssueDetailsParticipationDto>[])
    List<IssueDetailsParticipationDto> characters,
    @JsonKey(name: 'teams')
    @Default(<IssueDetailsParticipationDto>[])
    List<IssueDetailsParticipationDto> teams,
    @JsonKey(name: 'universes')
    @Default(<IssueDetailsParticipationDto>[])
    List<IssueDetailsParticipationDto> universes,
    @JsonKey(name: 'reprints')
    @Default(<IssueDetailsReprintDto>[])
    List<IssueDetailsReprintDto> reprints,
    @JsonKey(name: 'variants')
    @Default(<IssueDetailsVariantDto>[])
    List<IssueDetailsVariantDto> variants,
    @JsonKey(name: 'cv_id') int? cvId,
    @JsonKey(name: 'gcd_id') int? gcdId,
    @JsonKey(name: 'resource_url') String? resourceUrl,
    String? modified,
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
abstract class IssueDetailsNamedRefDto with _$IssueDetailsNamedRefDto {
  const factory IssueDetailsNamedRefDto({
    required int id,
    required String name,
  }) = _IssueDetailsNamedRefDto;

  factory IssueDetailsNamedRefDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsNamedRefDtoFromJson(json);

  const IssueDetailsNamedRefDto._();

  IssueDetailsNamedRef toEntity() => IssueDetailsNamedRef(id: id, name: name);
}

@freezed
abstract class IssueDetailsSeriesDto with _$IssueDetailsSeriesDto {
  const factory IssueDetailsSeriesDto({
    required int id,
    required String name,
    @JsonKey(name: 'sort_name') String? sortName,
    int? volume,
    @JsonKey(name: 'year_began') int? yearBegan,
    @JsonKey(name: 'series_type') IssueDetailsNamedRefDto? seriesType,
    @Default(<IssueDetailsNamedRefDto>[]) List<IssueDetailsNamedRefDto> genres,
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
abstract class IssueDetailsParticipationDto
    with _$IssueDetailsParticipationDto {
  const factory IssueDetailsParticipationDto({
    required int id,
    required String name,
    String? modified,
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
abstract class IssueDetailsCreditRoleDto with _$IssueDetailsCreditRoleDto {
  const factory IssueDetailsCreditRoleDto({
    required int id,
    required String name,
  }) = _IssueDetailsCreditRoleDto;

  factory IssueDetailsCreditRoleDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsCreditRoleDtoFromJson(json);

  const IssueDetailsCreditRoleDto._();

  IssueDetailsCreditRole toEntity() {
    return IssueDetailsCreditRole(id: id, name: name);
  }
}

@freezed
abstract class IssueDetailsCreditDto with _$IssueDetailsCreditDto {
  const factory IssueDetailsCreditDto({
    required int id,
    String? creator,
    @JsonKey(name: 'role')
    @Default(<IssueDetailsCreditRoleDto>[])
    List<IssueDetailsCreditRoleDto> roles,
    @JsonKey(name: 'creator_id') int? creatorId,
  }) = _IssueDetailsCreditDto;

  factory IssueDetailsCreditDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsCreditDtoFromJson(json);

  const IssueDetailsCreditDto._();

  IssueDetailsCredit toEntity() {
    return IssueDetailsCredit(
      id: id,
      creator: creator,
      creatorId: (creatorId != null && creatorId! > 0)
          ? creatorId
          : (id > 0 ? id : null),
      roles: roles.map((entry) => entry.toEntity()).toList(),
    );
  }
}

@freezed
abstract class IssueDetailsReprintDto with _$IssueDetailsReprintDto {
  const factory IssueDetailsReprintDto({required int id, String? issue}) =
      _IssueDetailsReprintDto;

  factory IssueDetailsReprintDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDetailsReprintDtoFromJson(json);

  const IssueDetailsReprintDto._();

  IssueDetailsReprint toEntity() => IssueDetailsReprint(id: id, issue: issue);
}

@freezed
abstract class IssueDetailsVariantDto with _$IssueDetailsVariantDto {
  const factory IssueDetailsVariantDto({
    String? name,
    String? price,
    String? sku,
    String? upc,
    String? image,
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
