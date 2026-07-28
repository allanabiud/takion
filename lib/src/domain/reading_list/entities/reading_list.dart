import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_list.freezed.dart';
part 'reading_list.g.dart';

enum ListContentType { series, issue }

enum ItemRole { standard, prologue, core, tieIn, epilogue }

@freezed
abstract class ReadingListItem with _$ReadingListItem {
  const factory ReadingListItem({
    required String targetId,
    required bool isSeries,
    required ItemRole role,
    required bool isRead,
  }) = _ReadingListItem;

  factory ReadingListItem.fromJson(Map<String, dynamic> json) =>
      _$ReadingListItemFromJson(json);
}

@freezed
abstract class ReadingList with _$ReadingList {
  const factory ReadingList({
    required String id,
    required String title,
    required String description,
    required bool isOrdered,
    required ListContentType contentType,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<ReadingListItem> items,
    int? metronSourceId,
    String? metronAttributionSource,
    String? metronAttributionUrl,
    String? metronImageUrl,
    String? metronListType,
    DateTime? lastSyncedAt,
  }) = _ReadingList;

  factory ReadingList.fromJson(Map<String, dynamic> json) =>
      _$ReadingListFromJson(json);
}
