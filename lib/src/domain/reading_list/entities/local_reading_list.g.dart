// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_reading_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalReadingListItem _$LocalReadingListItemFromJson(
  Map<String, dynamic> json,
) => _LocalReadingListItem(
  targetId: json['targetId'] as String,
  isSeries: json['isSeries'] as bool,
  role: $enumDecode(_$ItemRoleEnumMap, json['role']),
  isRead: json['isRead'] as bool,
  seriesName: json['seriesName'] as String?,
  seriesVolume: (json['seriesVolume'] as num?)?.toInt(),
  issueNumber: json['issueNumber'] as String?,
  seriesId: (json['seriesId'] as num?)?.toInt(),
  yearBegan: (json['yearBegan'] as num?)?.toInt(),
  coverDate: json['coverDate'] == null
      ? null
      : DateTime.parse(json['coverDate'] as String),
  storeDate: json['storeDate'] == null
      ? null
      : DateTime.parse(json['storeDate'] as String),
);

Map<String, dynamic> _$LocalReadingListItemToJson(
  _LocalReadingListItem instance,
) => <String, dynamic>{
  'targetId': instance.targetId,
  'isSeries': instance.isSeries,
  'role': _$ItemRoleEnumMap[instance.role]!,
  'isRead': instance.isRead,
  'seriesName': instance.seriesName,
  'seriesVolume': instance.seriesVolume,
  'issueNumber': instance.issueNumber,
  'seriesId': instance.seriesId,
  'yearBegan': instance.yearBegan,
  'coverDate': instance.coverDate?.toIso8601String(),
  'storeDate': instance.storeDate?.toIso8601String(),
};

const _$ItemRoleEnumMap = {
  ItemRole.standard: 'standard',
  ItemRole.prologue: 'prologue',
  ItemRole.core: 'core',
  ItemRole.tieIn: 'tieIn',
  ItemRole.epilogue: 'epilogue',
};

_LocalReadingList _$LocalReadingListFromJson(Map<String, dynamic> json) =>
    _LocalReadingList(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isOrdered: json['isOrdered'] as bool,
      contentType: $enumDecode(_$ListContentTypeEnumMap, json['contentType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => LocalReadingListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      metronSourceId: (json['metronSourceId'] as num?)?.toInt(),
      metronArcId: (json['metronArcId'] as num?)?.toInt(),
      metronAttributionSource: json['metronAttributionSource'] as String?,
      metronAttributionUrl: json['metronAttributionUrl'] as String?,
      metronImageUrl: json['metronImageUrl'] as String?,
      metronListType: json['metronListType'] as String?,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
    );

Map<String, dynamic> _$LocalReadingListToJson(_LocalReadingList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isOrdered': instance.isOrdered,
      'contentType': _$ListContentTypeEnumMap[instance.contentType]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'items': instance.items,
      'metronSourceId': instance.metronSourceId,
      'metronArcId': instance.metronArcId,
      'metronAttributionSource': instance.metronAttributionSource,
      'metronAttributionUrl': instance.metronAttributionUrl,
      'metronImageUrl': instance.metronImageUrl,
      'metronListType': instance.metronListType,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };

const _$ListContentTypeEnumMap = {
  ListContentType.series: 'series',
  ListContentType.issue: 'issue',
};
