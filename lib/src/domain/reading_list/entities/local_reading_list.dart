import 'package:freezed_annotation/freezed_annotation.dart';

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
    String? metronAttributionSource,
    String? metronAttributionUrl,
    String? metronImageUrl,
    String? metronListType,
    DateTime? lastSyncedAt,
  }) = _LocalReadingList;

  factory LocalReadingList.fromJson(Map<String, dynamic> json) =>
      _$LocalReadingListFromJson(json);
}
