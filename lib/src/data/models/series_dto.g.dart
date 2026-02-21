// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PublisherDtoAdapter extends TypeAdapter<PublisherDto> {
  @override
  final typeId = 2;

  @override
  PublisherDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PublisherDto(
      id: (fields[0] as num?)?.toInt(),
      name: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PublisherDto obj) {
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
      other is PublisherDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeriesDtoAdapter extends TypeAdapter<SeriesDto> {
  @override
  final typeId = 1;

  @override
  SeriesDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeriesDto(
      id: (fields[0] as num?)?.toInt(),
      name: fields[1] as String?,
      volume: (fields[2] as num?)?.toInt(),
      yearBegan: (fields[3] as num?)?.toInt(),
      publisherName: fields[4] as String?,
      description: fields[5] as String?,
      yearEnd: (fields[6] as num?)?.toInt(),
      issueCount: (fields[7] as num?)?.toInt(),
      seriesName: fields[8] as String?,
      publisher: fields[9] as PublisherDto?,
      seriesType: fields[10] as SeriesTypeDto?,
      status: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SeriesDto obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.volume)
      ..writeByte(3)
      ..write(obj.yearBegan)
      ..writeByte(4)
      ..write(obj.publisherName)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.yearEnd)
      ..writeByte(7)
      ..write(obj.issueCount)
      ..writeByte(8)
      ..write(obj.seriesName)
      ..writeByte(9)
      ..write(obj.publisher)
      ..writeByte(10)
      ..write(obj.seriesType)
      ..writeByte(11)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublisherDto _$PublisherDtoFromJson(Map<String, dynamic> json) =>
    _PublisherDto(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$PublisherDtoToJson(_PublisherDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_SeriesDto _$SeriesDtoFromJson(Map<String, dynamic> json) => _SeriesDto(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  volume: (json['volume'] as num?)?.toInt(),
  yearBegan: (json['year_began'] as num?)?.toInt(),
  publisherName: json['publisher_name'] as String?,
  description: json['desc'] as String?,
  yearEnd: (json['year_end'] as num?)?.toInt(),
  issueCount: (json['issue_count'] as num?)?.toInt(),
  seriesName: json['series'] as String?,
  publisher: json['publisher'] == null
      ? null
      : PublisherDto.fromJson(json['publisher'] as Map<String, dynamic>),
  seriesType: json['series_type'] == null
      ? null
      : SeriesTypeDto.fromJson(json['series_type'] as Map<String, dynamic>),
  status: json['status'] as String?,
);

Map<String, dynamic> _$SeriesDtoToJson(_SeriesDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'volume': instance.volume,
      'year_began': instance.yearBegan,
      'publisher_name': instance.publisherName,
      'desc': instance.description,
      'year_end': instance.yearEnd,
      'issue_count': instance.issueCount,
      'series': instance.seriesName,
      'publisher': instance.publisher,
      'series_type': instance.seriesType,
      'status': instance.status,
    };
