import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:takion/src/data/models/issue_list_series_dto.dart';
import 'package:takion/src/domain/entities/issue_list.dart';

part 'issue_list_dto.freezed.dart';
part 'issue_list_dto.g.dart';

@freezed
@HiveType(typeId: 0)
abstract class IssueListDto with _$IssueListDto {
  const factory IssueListDto({
    @HiveField(0) required int id,
    @HiveField(1) required String number,
    @HiveField(2) required IssueListSeriesDto? series,
    @HiveField(3) @JsonKey(name: 'cover_date') String? coverDate,
    @HiveField(4) @JsonKey(name: 'store_date') String? storeDate,
    @HiveField(5) required String? image,
    @HiveField(6) @JsonKey(name: 'issue') String? issueName,
    @HiveField(7) String? modified,
    @HiveField(8) @JsonKey(name: 'cover_hash') String? coverHash,
  }) = _IssueListDto;

  factory IssueListDto.fromJson(Map<String, dynamic> json) =>
      _$IssueListDtoFromJson(json);

  const IssueListDto._();

  IssueList toEntity() {
    // Changed to IssueList
    return IssueList(
      id: id,
      name: issueName ?? '${series?.name ?? 'IssueList'} #$number',
      number: number,
      series: series?.toEntity(),
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      image: image,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
