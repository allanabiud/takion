import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:takion/src/data/catalog/dto/dto.dart';
import 'package:takion/src/domain/entities.dart';

part 'issue_list_dto.freezed.dart';
part 'issue_list_dto.g.dart';

@freezed
abstract class IssueListDto with _$IssueListDto {
  const factory IssueListDto({
    required int id,
    required String number,
    required IssueListSeriesDto? series,
    @JsonKey(name: 'cover_date') String? coverDate,
    @JsonKey(name: 'store_date') String? storeDate,
    required String? image,
    @JsonKey(name: 'issue') String? issueName,
    String? modified,
    @JsonKey(name: 'cover_hash') String? coverHash,
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
