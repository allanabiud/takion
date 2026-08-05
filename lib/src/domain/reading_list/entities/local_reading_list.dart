import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:takion/src/domain/catalog/entities/entities.dart';

part 'local_reading_list.freezed.dart';
part 'local_reading_list.g.dart';

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

  factory LocalReadingListItem.fromJson(Map<String, dynamic> json) =>
      _$LocalReadingListItemFromJson(json);
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

  factory LocalReadingList.fromJson(Map<String, dynamic> json) =>
      _$LocalReadingListFromJson(json);
}

extension LocalReadingListExtensions on LocalReadingList {
  bool get isMetronImported => metronSourceId != null || metronArcId != null;
}

LocalReadingListItem localReadingListItemFromIssueList(IssueList issue) {
  return LocalReadingListItem(
    targetId: 'issue-${issue.id}',
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
