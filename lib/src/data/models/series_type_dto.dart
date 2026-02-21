import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

part 'series_type_dto.freezed.dart';
part 'series_type_dto.g.dart';

@freezed
@HiveType(typeId: 6)
abstract class SeriesTypeDto with _$SeriesTypeDto {
  const factory SeriesTypeDto({
    @HiveField(0) required int id,
    @HiveField(1) required String name,
  }) = _SeriesTypeDto;

  factory SeriesTypeDto.fromJson(Map<String, dynamic> json) =>
      _$SeriesTypeDtoFromJson(json);
}
