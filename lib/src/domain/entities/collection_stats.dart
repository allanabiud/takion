import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_stats.freezed.dart';

@freezed
abstract class CollectionStats with _$CollectionStats {
  const factory CollectionStats({
    required int totalItems,
    required int readCount,
    required String totalValue,
  }) = _CollectionStats;
}
