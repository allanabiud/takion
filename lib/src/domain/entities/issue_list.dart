import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:takion/src/domain/entities/series.dart';

part 'issue_list.freezed.dart';

@freezed
abstract class IssueList with _$IssueList {
  const factory IssueList({
    int? id,
    required String name,
    required String number,
    required Series? series,
    required DateTime? coverDate,
    required DateTime? storeDate,
    required String? image,
    required DateTime? modified,
  }) = _IssueList;
}
