import 'package:freezed_annotation/freezed_annotation.dart';

part 'series.freezed.dart';

@freezed
abstract class Series with _$Series {
  const factory Series({
    required int id,
    required String name,
    required int? volume,
    required int? yearBegan,
    required int? yearEnd,
    required int? issueCount,
    required String? publisherName,
    required String? description,
  }) = _Series;
}
