// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_type_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeriesTypeDtoAdapter extends TypeAdapter<SeriesTypeDto> {
  @override
  final typeId = 6;

  @override
  SeriesTypeDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeriesTypeDto(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SeriesTypeDto obj) {
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
      other is SeriesTypeDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeriesTypeDto _$SeriesTypeDtoFromJson(Map<String, dynamic> json) =>
    _SeriesTypeDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$SeriesTypeDtoToJson(_SeriesTypeDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
