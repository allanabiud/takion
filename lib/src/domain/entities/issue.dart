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
    required String? image,
    required String? description,
  }) = _Issue;
}
