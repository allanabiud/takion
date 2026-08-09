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

  factory IssueListDto.fromJson(Map<String, dynamic> json) {
    IssueListSeriesDto? parseSeries(dynamic s) {
      if (s == null) return null;
      if (s is Map<String, dynamic>) return IssueListSeriesDto.fromJson(s);
      if (s is Map) return IssueListSeriesDto.fromJson(Map<String, dynamic>.from(s));
      if (s is String && s.trim().isNotEmpty) {
        return IssueListSeriesDto(name: s.trim(), volume: 1, yearBegan: 0);
      }
      return null;
    }

    String? parseIssueName(dynamic issue) {
      if (issue == null) return null;
      if (issue is String) return issue;
      if (issue is Map) {
        return issue['name']?.toString() ?? issue['issue']?.toString();
      }
      return issue.toString();
    }

    return IssueListDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      number: json['number']?.toString() ?? '',
      series: parseSeries(json['series']),
      coverDate: json['cover_date']?.toString(),
      storeDate: json['store_date']?.toString(),
      image: json['image']?.toString(),
      issueName: parseIssueName(json['issue']),
      modified: json['modified']?.toString(),
      coverHash: json['cover_hash']?.toString(),
    );
  }

  const IssueListDto._();

  IssueList toEntity() {
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
