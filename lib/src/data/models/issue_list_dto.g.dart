// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_list_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IssueListDtoAdapter extends TypeAdapter<IssueListDto> {
  @override
  final typeId = 0;

  @override
  IssueListDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueListDto(
      id: (fields[0] as num).toInt(),
      number: fields[1] as String,
      series: fields[2] as IssueListSeriesDto?,
      coverDate: fields[3] as String?,
      storeDate: fields[4] as String?,
      image: fields[5] as String?,
      issueName: fields[6] as String?,
      modified: fields[7] as String?,
      coverHash: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueListDto obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.series)
      ..writeByte(3)
      ..write(obj.coverDate)
      ..writeByte(4)
      ..write(obj.storeDate)
      ..writeByte(5)
      ..write(obj.image)
      ..writeByte(6)
      ..write(obj.issueName)
      ..writeByte(7)
      ..write(obj.modified)
      ..writeByte(8)
      ..write(obj.coverHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueListDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueListDto _$IssueListDtoFromJson(Map<String, dynamic> json) =>
    _IssueListDto(
      id: (json['id'] as num).toInt(),
      number: json['number'] as String,
      series: json['series'] == null
          ? null
          : IssueListSeriesDto.fromJson(json['series'] as Map<String, dynamic>),
      coverDate: json['cover_date'] as String?,
      storeDate: json['store_date'] as String?,
      image: json['image'] as String?,
      issueName: json['issue'] as String?,
      modified: json['modified'] as String?,
      coverHash: json['cover_hash'] as String?,
    );

Map<String, dynamic> _$IssueListDtoToJson(_IssueListDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'series': instance.series,
      'cover_date': instance.coverDate,
      'store_date': instance.storeDate,
      'image': instance.image,
      'issue': instance.issueName,
      'modified': instance.modified,
      'cover_hash': instance.coverHash,
    };
