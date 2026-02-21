import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:takion/src/domain/entities/collection_stats.dart';

part 'collection_stats_dto.freezed.dart';
part 'collection_stats_dto.g.dart';

@freezed
@HiveType(typeId: 5)
abstract class CollectionStatsDto with _$CollectionStatsDto {
  const factory CollectionStatsDto({
    @HiveField(0) @JsonKey(name: 'total_items') required int totalItems,
    @HiveField(1) @JsonKey(name: 'read_count') required int readCount,
    @HiveField(2) @JsonKey(name: 'total_value') required String totalValue,
  }) = _CollectionStatsDto;

  factory CollectionStatsDto.fromJson(Map<String, dynamic> json) =>
      _$CollectionStatsDtoFromJson(json);

  const CollectionStatsDto._();

  CollectionStats toEntity() {
    return CollectionStats(
      totalItems: totalItems,
      readCount: readCount,
      totalValue: totalValue,
    );
  }
}
