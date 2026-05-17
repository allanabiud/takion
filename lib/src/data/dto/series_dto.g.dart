// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      seriesName: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SeriesDto obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.seriesName);
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

_SeriesDto _$SeriesDtoFromJson(Map<String, dynamic> json) => _SeriesDto(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  volume: (json['volume'] as num?)?.toInt(),
  yearBegan: (json['year_began'] as num?)?.toInt(),
  publisherName: json['publisher_name'] as String?,
  description: json['desc'] as String?,
  seriesName: json['series'] as String?,
);

Map<String, dynamic> _$SeriesDtoToJson(_SeriesDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'volume': instance.volume,
      'year_began': instance.yearBegan,
      'publisher_name': instance.publisherName,
      'desc': instance.description,
      'series': instance.seriesName,
    };
