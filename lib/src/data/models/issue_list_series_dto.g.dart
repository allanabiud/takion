// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_list_series_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IssueListSeriesDtoAdapter extends TypeAdapter<IssueListSeriesDto> {
  @override
  final typeId = 3;

  @override
  IssueListSeriesDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueListSeriesDto(
      name: fields[0] as String,
      volume: (fields[1] as num).toInt(),
      yearBegan: (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, IssueListSeriesDto obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.volume)
      ..writeByte(2)
      ..write(obj.yearBegan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueListSeriesDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueListSeriesDto _$IssueListSeriesDtoFromJson(Map<String, dynamic> json) =>
    _IssueListSeriesDto(
      name: json['name'] as String,
      volume: (json['volume'] as num).toInt(),
      yearBegan: (json['year_began'] as num).toInt(),
    );

Map<String, dynamic> _$IssueListSeriesDtoToJson(_IssueListSeriesDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'volume': instance.volume,
      'year_began': instance.yearBegan,
    };
