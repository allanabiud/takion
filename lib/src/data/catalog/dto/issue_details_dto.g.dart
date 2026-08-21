// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_details_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueDetailsDto _$IssueDetailsDtoFromJson(Map<String, dynamic> json) =>
    _IssueDetailsDto(
      id: (json['id'] as num).toInt(),
      publisher: json['publisher'] == null
          ? null
          : IssueDetailsNamedRefDto.fromJson(
              json['publisher'] as Map<String, dynamic>,
            ),
      imprint: json['imprint'] == null
          ? null
          : IssueDetailsNamedRefDto.fromJson(
              json['imprint'] as Map<String, dynamic>,
            ),
      series: json['series'] == null
          ? null
          : IssueDetailsSeriesDto.fromJson(
              json['series'] as Map<String, dynamic>,
            ),
      number: json['number'] as String,
      altNumber: json['alt_number'] as String?,
      title: json['title'] as String?,
      names:
          (json['name'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      coverDate: json['cover_date'] as String?,
      storeDate: json['store_date'] as String?,
      focDate: json['foc_date'] as String?,
      price: json['price'] as String?,
      priceCurrency: json['price_currency'] as String?,
      rating: json['rating'] == null
          ? null
          : IssueDetailsNamedRefDto.fromJson(
              json['rating'] as Map<String, dynamic>,
            ),
      sku: json['sku'] as String?,
      isbn: json['isbn'] as String?,
      upc: json['upc'] as String?,
      page: (json['page'] as num?)?.toInt(),
      description: json['desc'] as String?,
      image: json['image'] as String?,
      coverHash: json['cover_hash'] as String?,
      arcs:
          (json['arcs'] as List<dynamic>?)
              ?.map(
                (e) => IssueDetailsParticipationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <IssueDetailsParticipationDto>[],
      credits:
          (json['credits'] as List<dynamic>?)
              ?.map(
                (e) =>
                    IssueDetailsCreditDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <IssueDetailsCreditDto>[],
      characters:
          (json['characters'] as List<dynamic>?)
              ?.map(
                (e) => IssueDetailsParticipationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <IssueDetailsParticipationDto>[],
      teams:
          (json['teams'] as List<dynamic>?)
              ?.map(
                (e) => IssueDetailsParticipationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <IssueDetailsParticipationDto>[],
      universes:
          (json['universes'] as List<dynamic>?)
              ?.map(
                (e) => IssueDetailsParticipationDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <IssueDetailsParticipationDto>[],
      reprints:
          (json['reprints'] as List<dynamic>?)
              ?.map(
                (e) =>
                    IssueDetailsReprintDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <IssueDetailsReprintDto>[],
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map(
                (e) =>
                    IssueDetailsVariantDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <IssueDetailsVariantDto>[],
      cvId: (json['cv_id'] as num?)?.toInt(),
      gcdId: (json['gcd_id'] as num?)?.toInt(),
      resourceUrl: json['resource_url'] as String?,
      modified: json['modified'] as String?,
    );

Map<String, dynamic> _$IssueDetailsDtoToJson(_IssueDetailsDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publisher': instance.publisher,
      'imprint': instance.imprint,
      'series': instance.series,
      'number': instance.number,
      'alt_number': instance.altNumber,
      'title': instance.title,
      'name': instance.names,
      'cover_date': instance.coverDate,
      'store_date': instance.storeDate,
      'foc_date': instance.focDate,
      'price': instance.price,
      'price_currency': instance.priceCurrency,
      'rating': instance.rating,
      'sku': instance.sku,
      'isbn': instance.isbn,
      'upc': instance.upc,
      'page': instance.page,
      'desc': instance.description,
      'image': instance.image,
      'cover_hash': instance.coverHash,
      'arcs': instance.arcs,
      'credits': instance.credits,
      'characters': instance.characters,
      'teams': instance.teams,
      'universes': instance.universes,
      'reprints': instance.reprints,
      'variants': instance.variants,
      'cv_id': instance.cvId,
      'gcd_id': instance.gcdId,
      'resource_url': instance.resourceUrl,
      'modified': instance.modified,
    };

_IssueDetailsNamedRefDto _$IssueDetailsNamedRefDtoFromJson(
  Map<String, dynamic> json,
) => _IssueDetailsNamedRefDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$IssueDetailsNamedRefDtoToJson(
  _IssueDetailsNamedRefDto instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_IssueDetailsSeriesDto _$IssueDetailsSeriesDtoFromJson(
  Map<String, dynamic> json,
) => _IssueDetailsSeriesDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  sortName: json['sort_name'] as String?,
  volume: (json['volume'] as num?)?.toInt(),
  yearBegan: (json['year_began'] as num?)?.toInt(),
  seriesType: json['series_type'] == null
      ? null
      : IssueDetailsNamedRefDto.fromJson(
          json['series_type'] as Map<String, dynamic>,
        ),
  genres:
      (json['genres'] as List<dynamic>?)
          ?.map(
            (e) => IssueDetailsNamedRefDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <IssueDetailsNamedRefDto>[],
);

Map<String, dynamic> _$IssueDetailsSeriesDtoToJson(
  _IssueDetailsSeriesDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sort_name': instance.sortName,
  'volume': instance.volume,
  'year_began': instance.yearBegan,
  'series_type': instance.seriesType,
  'genres': instance.genres,
};

_IssueDetailsParticipationDto _$IssueDetailsParticipationDtoFromJson(
  Map<String, dynamic> json,
) => _IssueDetailsParticipationDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  modified: json['modified'] as String?,
);

Map<String, dynamic> _$IssueDetailsParticipationDtoToJson(
  _IssueDetailsParticipationDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'modified': instance.modified,
};

_IssueDetailsCreditRoleDto _$IssueDetailsCreditRoleDtoFromJson(
  Map<String, dynamic> json,
) => _IssueDetailsCreditRoleDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$IssueDetailsCreditRoleDtoToJson(
  _IssueDetailsCreditRoleDto instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_IssueDetailsCreditDto _$IssueDetailsCreditDtoFromJson(
  Map<String, dynamic> json,
) => _IssueDetailsCreditDto(
  id: (json['id'] as num).toInt(),
  creator: json['creator'] as String?,
  roles:
      (json['role'] as List<dynamic>?)
          ?.map(
            (e) =>
                IssueDetailsCreditRoleDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <IssueDetailsCreditRoleDto>[],
  creatorId: (json['creator_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$IssueDetailsCreditDtoToJson(
  _IssueDetailsCreditDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'creator': instance.creator,
  'role': instance.roles,
  'creator_id': instance.creatorId,
};

_IssueDetailsReprintDto _$IssueDetailsReprintDtoFromJson(
  Map<String, dynamic> json,
) => _IssueDetailsReprintDto(
  id: (json['id'] as num).toInt(),
  issue: json['issue'] as String?,
);

Map<String, dynamic> _$IssueDetailsReprintDtoToJson(
  _IssueDetailsReprintDto instance,
) => <String, dynamic>{'id': instance.id, 'issue': instance.issue};

_IssueDetailsVariantDto _$IssueDetailsVariantDtoFromJson(
  Map<String, dynamic> json,
) => _IssueDetailsVariantDto(
  name: json['name'] as String?,
  price: json['price'] as String?,
  sku: json['sku'] as String?,
  upc: json['upc'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$IssueDetailsVariantDtoToJson(
  _IssueDetailsVariantDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'price': instance.price,
  'sku': instance.sku,
  'upc': instance.upc,
  'image': instance.image,
};
