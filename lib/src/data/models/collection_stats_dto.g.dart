// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_stats_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectionStatsDtoAdapter extends TypeAdapter<CollectionStatsDto> {
  @override
  final typeId = 5;

  @override
  CollectionStatsDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionStatsDto(
      totalItems: (fields[0] as num).toInt(),
      readCount: (fields[1] as num).toInt(),
      totalValue: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CollectionStatsDto obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalItems)
      ..writeByte(1)
      ..write(obj.readCount)
      ..writeByte(2)
      ..write(obj.totalValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionStatsDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CollectionStatsDto _$CollectionStatsDtoFromJson(Map<String, dynamic> json) =>
    _CollectionStatsDto(
      totalItems: (json['total_items'] as num).toInt(),
      readCount: (json['read_count'] as num).toInt(),
      totalValue: json['total_value'] as String,
    );

Map<String, dynamic> _$CollectionStatsDtoToJson(_CollectionStatsDto instance) =>
    <String, dynamic>{
      'total_items': instance.totalItems,
      'read_count': instance.readCount,
      'total_value': instance.totalValue,
    };
