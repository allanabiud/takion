// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingListItemAdapter extends TypeAdapter<ReadingListItem> {
  @override
  final typeId = 22;

  @override
  ReadingListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingListItem(
      targetId: fields[0] as String,
      isSeries: fields[1] as bool,
      role: fields[2] as ItemRole,
      isRead: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingListItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.targetId)
      ..writeByte(1)
      ..write(obj.isSeries)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReadingListAdapter extends TypeAdapter<ReadingList> {
  @override
  final typeId = 23;

  @override
  ReadingList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingList(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      isOrdered: fields[3] as bool,
      contentType: fields[4] as ListContentType,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      items: (fields[7] as List).cast<ReadingListItem>(),
      metronSourceId: (fields[8] as num?)?.toInt(),
      metronAttributionSource: fields[9] as String?,
      metronAttributionUrl: fields[10] as String?,
      metronImageUrl: fields[11] as String?,
      metronListType: fields[12] as String?,
      lastSyncedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingList obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isOrdered)
      ..writeByte(4)
      ..write(obj.contentType)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.items)
      ..writeByte(8)
      ..write(obj.metronSourceId)
      ..writeByte(9)
      ..write(obj.metronAttributionSource)
      ..writeByte(10)
      ..write(obj.metronAttributionUrl)
      ..writeByte(11)
      ..write(obj.metronImageUrl)
      ..writeByte(12)
      ..write(obj.metronListType)
      ..writeByte(13)
      ..write(obj.lastSyncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListContentTypeAdapter extends TypeAdapter<ListContentType> {
  @override
  final typeId = 20;

  @override
  ListContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ListContentType.series;
      case 1:
        return ListContentType.issue;
      default:
        return ListContentType.series;
    }
  }

  @override
  void write(BinaryWriter writer, ListContentType obj) {
    switch (obj) {
      case ListContentType.series:
        writer.writeByte(0);
      case ListContentType.issue:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemRoleAdapter extends TypeAdapter<ItemRole> {
  @override
  final typeId = 21;

  @override
  ItemRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemRole.standard;
      case 1:
        return ItemRole.prologue;
      case 2:
        return ItemRole.core;
      case 3:
        return ItemRole.tieIn;
      case 4:
        return ItemRole.epilogue;
      default:
        return ItemRole.standard;
    }
  }

  @override
  void write(BinaryWriter writer, ItemRole obj) {
    switch (obj) {
      case ItemRole.standard:
        writer.writeByte(0);
      case ItemRole.prologue:
        writer.writeByte(1);
      case ItemRole.core:
        writer.writeByte(2);
      case ItemRole.tieIn:
        writer.writeByte(3);
      case ItemRole.epilogue:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadingListItem _$ReadingListItemFromJson(Map<String, dynamic> json) =>
    _ReadingListItem(
      targetId: json['targetId'] as String,
      isSeries: json['isSeries'] as bool,
      role: $enumDecode(_$ItemRoleEnumMap, json['role']),
      isRead: json['isRead'] as bool,
    );

Map<String, dynamic> _$ReadingListItemToJson(_ReadingListItem instance) =>
    <String, dynamic>{
      'targetId': instance.targetId,
      'isSeries': instance.isSeries,
      'role': _$ItemRoleEnumMap[instance.role]!,
      'isRead': instance.isRead,
    };

const _$ItemRoleEnumMap = {
  ItemRole.standard: 'standard',
  ItemRole.prologue: 'prologue',
  ItemRole.core: 'core',
  ItemRole.tieIn: 'tieIn',
  ItemRole.epilogue: 'epilogue',
};

_ReadingList _$ReadingListFromJson(Map<String, dynamic> json) => _ReadingList(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  isOrdered: json['isOrdered'] as bool,
  contentType: $enumDecode(_$ListContentTypeEnumMap, json['contentType']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  items: (json['items'] as List<dynamic>)
      .map((e) => ReadingListItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  metronSourceId: (json['metronSourceId'] as num?)?.toInt(),
  metronAttributionSource: json['metronAttributionSource'] as String?,
  metronAttributionUrl: json['metronAttributionUrl'] as String?,
  metronImageUrl: json['metronImageUrl'] as String?,
  metronListType: json['metronListType'] as String?,
  lastSyncedAt: json['lastSyncedAt'] == null
      ? null
      : DateTime.parse(json['lastSyncedAt'] as String),
);

Map<String, dynamic> _$ReadingListToJson(_ReadingList instance) =>
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
