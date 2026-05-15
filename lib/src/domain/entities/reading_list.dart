import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'reading_list.freezed.dart';
part 'reading_list.g.dart';

@HiveType(typeId: 20) // Use an available ID
enum ListContentType {
  @HiveField(0) series,
  @HiveField(1) issue,
}

@HiveType(typeId: 21)
enum ItemRole {
  @HiveField(0) standard,
  @HiveField(1) prologue,
  @HiveField(2) core,
  @HiveField(3) tieIn,
  @HiveField(4) epilogue,
}

@freezed
@HiveType(typeId: 22)
abstract class ReadingListItem with _$ReadingListItem {
  const factory ReadingListItem({
    @HiveField(0) required String targetId,
    @HiveField(1) required bool isSeries,
    @HiveField(2) required ItemRole role,
    @HiveField(3) required bool isRead,
  }) = _ReadingListItem;

  factory ReadingListItem.fromJson(Map<String, dynamic> json) =>
      _$ReadingListItemFromJson(json);
}

@freezed
@HiveType(typeId: 23)
abstract class ReadingList with _$ReadingList {
  const factory ReadingList({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required bool isOrdered,
    @HiveField(4) required ListContentType contentType,
    @HiveField(5) required DateTime createdAt,
    @HiveField(6) required DateTime updatedAt,
    @HiveField(7) required List<ReadingListItem> items,
  }) = _ReadingList;

  factory ReadingList.fromJson(Map<String, dynamic> json) =>
      _$ReadingListFromJson(json);
}
