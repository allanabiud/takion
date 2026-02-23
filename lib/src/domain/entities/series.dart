import 'package:freezed_annotation/freezed_annotation.dart';

part 'series.freezed.dart';

@freezed
abstract class Series with _$Series {
  const factory Series({
    int? id,
    required String name,
    required int? volume,
    required int? yearBegan,
    String? publisherName,
    String? description,
  }) = _Series;
}
