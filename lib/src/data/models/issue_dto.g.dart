// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IssueDtoAdapter extends TypeAdapter<IssueDto> {
  @override
  final typeId = 0;

  @override
  IssueDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueDto(
      id: (fields[0] as num).toInt(),
      number: fields[1] as String,
      series: fields[2] as SeriesDto?,
      storeDate: fields[3] as String?,
      image: fields[4] as String?,
      description: fields[5] as String?,
      issueName: fields[6] as String?,
      coverDate: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueDto obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.series)
      ..writeByte(3)
      ..write(obj.storeDate)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.issueName)
      ..writeByte(7)
      ..write(obj.coverDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueDto _$IssueDtoFromJson(Map<String, dynamic> json) => _IssueDto(
  id: (json['id'] as num).toInt(),
  number: json['number'] as String,
  series: json['series'] == null
      ? null
      : SeriesDto.fromJson(json['series'] as Map<String, dynamic>),
  storeDate: json['store_date'] as String?,
  image: json['image'] as String?,
  description: json['desc'] as String?,
  issueName: json['issue'] as String?,
  coverDate: json['cover_date'] as String?,
);

Map<String, dynamic> _$IssueDtoToJson(_IssueDto instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'series': instance.series,
  'store_date': instance.storeDate,
  'image': instance.image,
  'desc': instance.description,
  'issue': instance.issueName,
  'cover_date': instance.coverDate,
};
