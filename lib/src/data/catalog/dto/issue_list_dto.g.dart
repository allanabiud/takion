// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_list_dto.dart';

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
