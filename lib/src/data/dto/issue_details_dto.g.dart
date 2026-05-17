// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_details_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IssueDetailsDtoAdapter extends TypeAdapter<IssueDetailsDto> {
  @override
  final typeId = 10;

  @override
  IssueDetailsDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDetailsDto(
      id: (fields[0] as num).toInt(),
      publisher: fields[1] as IssueDetailsNamedRefDto?,
      imprint: fields[2] as IssueDetailsNamedRefDto?,
      series: fields[3] as IssueDetailsSeriesDto?,
      number: fields[4] as String,
      altNumber: fields[5] as String?,
      title: fields[6] as String?,
      names: fields[7] == null ? [] : (fields[7] as List).cast<String>(),
      coverDate: fields[8] as String?,
      storeDate: fields[9] as String?,
      focDate: fields[10] as String?,
      price: fields[11] as String?,
      priceCurrency: fields[12] as String?,
      rating: fields[13] as IssueDetailsNamedRefDto?,
      sku: fields[14] as String?,
      isbn: fields[15] as String?,
      upc: fields[16] as String?,
      page: (fields[17] as num?)?.toInt(),
      description: fields[18] as String?,
      image: fields[19] as String?,
      coverHash: fields[20] as String?,
      arcs: fields[21] == null
          ? []
          : (fields[21] as List).cast<IssueDetailsParticipationDto>(),
      credits: fields[22] == null
          ? []
          : (fields[22] as List).cast<IssueDetailsCreditDto>(),
      characters: fields[23] == null
          ? []
          : (fields[23] as List).cast<IssueDetailsParticipationDto>(),
      teams: fields[24] == null
          ? []
          : (fields[24] as List).cast<IssueDetailsParticipationDto>(),
      universes: fields[25] == null
          ? []
          : (fields[25] as List).cast<IssueDetailsParticipationDto>(),
      reprints: fields[26] == null
          ? []
          : (fields[26] as List).cast<IssueDetailsReprintDto>(),
      variants: fields[27] == null
          ? []
          : (fields[27] as List).cast<IssueDetailsVariantDto>(),
      cvId: (fields[28] as num?)?.toInt(),
      gcdId: (fields[29] as num?)?.toInt(),
      resourceUrl: fields[30] as String?,
      modified: fields[31] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueDetailsDto obj) {
    writer
      ..writeByte(32)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.publisher)
      ..writeByte(2)
      ..write(obj.imprint)
      ..writeByte(3)
      ..write(obj.series)
      ..writeByte(4)
      ..write(obj.number)
      ..writeByte(5)
      ..write(obj.altNumber)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.names)
      ..writeByte(8)
      ..write(obj.coverDate)
      ..writeByte(9)
      ..write(obj.storeDate)
      ..writeByte(10)
      ..write(obj.focDate)
      ..writeByte(11)
      ..write(obj.price)
      ..writeByte(12)
      ..write(obj.priceCurrency)
      ..writeByte(13)
      ..write(obj.rating)
      ..writeByte(14)
      ..write(obj.sku)
      ..writeByte(15)
      ..write(obj.isbn)
      ..writeByte(16)
      ..write(obj.upc)
      ..writeByte(17)
      ..write(obj.page)
      ..writeByte(18)
      ..write(obj.description)
      ..writeByte(19)
      ..write(obj.image)
      ..writeByte(20)
      ..write(obj.coverHash)
      ..writeByte(21)
      ..write(obj.arcs)
      ..writeByte(22)
      ..write(obj.credits)
      ..writeByte(23)
      ..write(obj.characters)
      ..writeByte(24)
      ..write(obj.teams)
      ..writeByte(25)
      ..write(obj.universes)
      ..writeByte(26)
      ..write(obj.reprints)
      ..writeByte(27)
      ..write(obj.variants)
      ..writeByte(28)
      ..write(obj.cvId)
      ..writeByte(29)
      ..write(obj.gcdId)
      ..writeByte(30)
      ..write(obj.resourceUrl)
      ..writeByte(31)
      ..write(obj.modified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDetailsDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueDetailsNamedRefDtoAdapter
    extends TypeAdapter<IssueDetailsNamedRefDto> {
  @override
  final typeId = 11;

  @override
  IssueDetailsNamedRefDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDetailsNamedRefDto(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IssueDetailsNamedRefDto obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDetailsNamedRefDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueDetailsSeriesDtoAdapter extends TypeAdapter<IssueDetailsSeriesDto> {
  @override
  final typeId = 12;

  @override
  IssueDetailsSeriesDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDetailsSeriesDto(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      sortName: fields[2] as String?,
      volume: (fields[3] as num?)?.toInt(),
      yearBegan: (fields[4] as num?)?.toInt(),
      seriesType: fields[5] as IssueDetailsNamedRefDto?,
      genres: fields[6] == null
          ? []
          : (fields[6] as List).cast<IssueDetailsNamedRefDto>(),
    );
  }

  @override
  void write(BinaryWriter writer, IssueDetailsSeriesDto obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sortName)
      ..writeByte(3)
      ..write(obj.volume)
      ..writeByte(4)
      ..write(obj.yearBegan)
      ..writeByte(5)
      ..write(obj.seriesType)
      ..writeByte(6)
      ..write(obj.genres);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDetailsSeriesDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueDetailsParticipationDtoAdapter
    extends TypeAdapter<IssueDetailsParticipationDto> {
  @override
  final typeId = 13;

  @override
  IssueDetailsParticipationDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDetailsParticipationDto(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      modified: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueDetailsParticipationDto obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.modified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDetailsParticipationDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueDetailsCreditRoleDtoAdapter
    extends TypeAdapter<IssueDetailsCreditRoleDto> {
  @override
  final typeId = 14;

  @override
  IssueDetailsCreditRoleDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDetailsCreditRoleDto(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IssueDetailsCreditRoleDto obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDetailsCreditRoleDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueDetailsCreditDtoAdapter extends TypeAdapter<IssueDetailsCreditDto> {
  @override
  final typeId = 15;

  @override
  IssueDetailsCreditDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDetailsCreditDto(
      id: (fields[0] as num).toInt(),
      creator: fields[1] as String?,
      roles: fields[2] == null
          ? []
          : (fields[2] as List).cast<IssueDetailsCreditRoleDto>(),
    );
  }

  @override
  void write(BinaryWriter writer, IssueDetailsCreditDto obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creator)
      ..writeByte(2)
      ..write(obj.roles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDetailsCreditDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueDetailsReprintDtoAdapter
    extends TypeAdapter<IssueDetailsReprintDto> {
  @override
  final typeId = 16;

  @override
  IssueDetailsReprintDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDetailsReprintDto(
      id: (fields[0] as num).toInt(),
      issue: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueDetailsReprintDto obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.issue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDetailsReprintDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueDetailsVariantDtoAdapter
    extends TypeAdapter<IssueDetailsVariantDto> {
  @override
  final typeId = 17;

  @override
  IssueDetailsVariantDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDetailsVariantDto(
      name: fields[0] as String?,
      price: fields[1] as String?,
      sku: fields[2] as String?,
      upc: fields[3] as String?,
      image: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueDetailsVariantDto obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.sku)
      ..writeByte(3)
      ..write(obj.upc)
      ..writeByte(4)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDetailsVariantDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
);

Map<String, dynamic> _$IssueDetailsCreditDtoToJson(
  _IssueDetailsCreditDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'creator': instance.creator,
  'role': instance.roles,
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
