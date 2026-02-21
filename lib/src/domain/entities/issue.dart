import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue.freezed.dart';

@freezed
abstract class Issue with _$Issue {
  const factory Issue({
    required int id,
    required String name,
    required String number,
    required String? seriesName,
    required String? publisherName,
    required DateTime? storeDate,
    required DateTime? coverDate,
    required String? image,
    required String? description,
    @Default(false) bool isCollected,
    @Default(false) bool isRead,
  }) = _Issue;
}
