// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_dto.dart';

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
