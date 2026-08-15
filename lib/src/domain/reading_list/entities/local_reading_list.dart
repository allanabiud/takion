import "package:freezed_annotation/freezed_annotation.dart";

import "package:takion/src/domain/catalog/entities/entities.dart";

part "local_reading_list.freezed.dart";
part "local_reading_list.g.dart";

enum ListContentType { series, issue }

enum ItemRole { standard, prologue, core, tieIn, epilogue }

@freezed
abstract class LocalReadingListItem with _$LocalReadingListItem {
  const factory LocalReadingListItem({
    required String targetId,
    required bool isSeries,
    required ItemRole role,
    required bool isRead,
    String? seriesName,
    int? seriesVolume,
    String? issueNumber,
    int? seriesId,
    int? yearBegan,
    DateTime? coverDate,
    DateTime? storeDate,
  }) = _LocalReadingListItem;

  factory LocalReadingListItem.fromJson(Map<String, dynamic> json) {
    return LocalReadingListItem(
      targetId: json["targetId"]?.toString() ?? "",
      isSeries: json["isSeries"] as bool? ?? false,
      role: json["role"] != null
          ? ItemRole.values.firstWhere(
              (e) => e.name == json["role"],
              orElse: () => ItemRole.standard,
            )
          : ItemRole.standard,
      isRead: json["isRead"] as bool? ?? false,
      seriesName: json["seriesName"]?.toString(),
      seriesVolume: (json["seriesVolume"] as num?)?.toInt(),
      issueNumber: json["issueNumber"]?.toString(),
      seriesId: (json["seriesId"] as num?)?.toInt(),
      yearBegan: (json["yearBegan"] as num?)?.toInt(),
      coverDate: json["coverDate"] != null
          ? DateTime.tryParse(json["coverDate"].toString())
          : null,
      storeDate: json["storeDate"] != null
          ? DateTime.tryParse(json["storeDate"].toString())
          : null,
    );
  }
}

@freezed
abstract class LocalReadingList with _$LocalReadingList {
  const factory LocalReadingList({
    required String id,
    required String title,
    required String description,
    required bool isOrdered,
    required ListContentType contentType,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<LocalReadingListItem> items,
    int? metronSourceId,
    int? metronArcId,
    String? metronAttributionSource,
    String? metronAttributionUrl,
    String? metronImageUrl,
    String? metronListType,
    DateTime? lastSyncedAt,
  }) = _LocalReadingList;

  factory LocalReadingList.fromJson(Map<String, dynamic> json) {
    final rawItems = json["items"];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => LocalReadingListItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <LocalReadingListItem>[];

    return LocalReadingList(
      id: json["id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      isOrdered: json["isOrdered"] as bool? ?? true,
      contentType: json["contentType"] != null
          ? ListContentType.values.firstWhere(
              (e) => e.name == json["contentType"],
              orElse: () => ListContentType.issue,
            )
          : ListContentType.issue,
      createdAt: json["createdAt"] != null
          ? (DateTime.tryParse(json["createdAt"].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json["updatedAt"] != null
          ? (DateTime.tryParse(json["updatedAt"].toString()) ?? DateTime.now())
          : DateTime.now(),
      items: items,
      metronSourceId: (json["metronSourceId"] as num?)?.toInt(),
      metronArcId: (json["metronArcId"] as num?)?.toInt(),
      metronAttributionSource: json["metronAttributionSource"]?.toString(),
      metronAttributionUrl: json["metronAttributionUrl"]?.toString(),
      metronImageUrl: json["metronImageUrl"]?.toString(),
      metronListType: json["metronListType"]?.toString(),
      lastSyncedAt: json["lastSyncedAt"] != null
          ? DateTime.tryParse(json["lastSyncedAt"].toString())
          : null,
    );
  }
}

extension LocalReadingListExtensions on LocalReadingList {
  bool get isMetronImported => metronSourceId != null || metronArcId != null;
}

LocalReadingListItem localReadingListItemFromIssueList(IssueList issue) {
  return LocalReadingListItem(
    targetId: "issue-${issue.id}",
    isSeries: false,
    role: ItemRole.standard,
    isRead: false,
    seriesName: issue.series?.name ?? issue.name,
    seriesVolume: issue.series?.volume,
    issueNumber: issue.number,
    seriesId: issue.series?.id,
    yearBegan: issue.series?.yearBegan,
    coverDate: issue.coverDate,
    storeDate: issue.storeDate,
  );
}
