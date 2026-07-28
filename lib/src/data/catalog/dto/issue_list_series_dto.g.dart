// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_list_series_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IssueListSeriesDto _$IssueListSeriesDtoFromJson(Map<String, dynamic> json) =>
    _IssueListSeriesDto(
      name: json['name'] as String,
      volume: (json['volume'] as num).toInt(),
      yearBegan: (json['year_began'] as num).toInt(),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$IssueListSeriesDtoToJson(_IssueListSeriesDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'volume': instance.volume,
      'year_began': instance.yearBegan,
      'id': instance.id,
    };
