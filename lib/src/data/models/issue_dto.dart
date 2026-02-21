import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:takion/src/data/models/series_dto.dart';
import 'package:takion/src/domain/entities/issue.dart';

part 'issue_dto.freezed.dart';
part 'issue_dto.g.dart';

@freezed
@HiveType(typeId: 0)
abstract class IssueDto with _$IssueDto {
  const factory IssueDto({
    @HiveField(0) required int id,
    @HiveField(1) required String number,
    @HiveField(2) required SeriesDto? series,
    @HiveField(3) @JsonKey(name: 'store_date') required String? storeDate,
    @HiveField(4) required String? image,
    @HiveField(5) @JsonKey(name: 'desc') required String? description,
    @HiveField(6) @JsonKey(name: 'issue') required String? issueName,
    @HiveField(7) @JsonKey(name: 'cover_date') String? coverDate,
  }) = _IssueDto;

  factory IssueDto.fromJson(Map<String, dynamic> json) => _$IssueDtoFromJson(json);

  const IssueDto._();

  Issue toEntity() {
    return Issue(
      id: id,
      name: issueName ?? '${series?.name ?? 'Issue'} #$number',
      number: number,
      seriesName: series?.name,
      publisherName: series?.publisherName ?? series?.publisher?.name,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      image: image,
      description: description,
    );
  }
}
