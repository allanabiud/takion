import "package:takion/src/core/constants/date_formatter.dart";

abstract final class MetronPageCacheKeys {
  static String weekKey(DateTime date) {
    final offset = date.weekday % 7;
    final sunday = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: offset));
    return "${sunday.year}-${sunday.month}-${sunday.day}";
  }

  static String normalizeSearchQuery(String query) => query.trim().toLowerCase();
  static String normalizeLimit(int? limit) =>
      limit != null && limit > 0 ? "$limit" : "";
  static String normalizeOrdering(String? ordering) => ordering?.trim() ?? "";
  static String normalizeModifiedGt(DateTime? modifiedGt) =>
      modifiedGt?.toUtc().toIso8601String() ?? "";
  static String normalizeStoreDate(DateTime? d) =>
      d == null ? "" : DateFormatter.isoDate(d);

  static String issueSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String issueList({
    required int page,
    String? ordering,
    DateTime? modifiedGt,
    int? limit,
  }) =>
      "issue_list:p$page:o${normalizeOrdering(ordering)}:m${normalizeModifiedGt(modifiedGt)}:l${normalizeLimit(limit)}";

  static String seriesIssueList(
    int seriesId,
    int page,
    int limit, {
    String? ordering,
    DateTime? storeDateGte,
    DateTime? storeDateLte,
  }) =>
      "series_issue_list:$seriesId:p$page:l${normalizeLimit(limit)}:o${normalizeOrdering(ordering)}:a${normalizeStoreDate(storeDateGte)}:b${normalizeStoreDate(storeDateLte)}";

  static String seriesSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String seriesList(int page, int limit, {DateTime? modifiedGt}) =>
      "series_list:p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}";

  static String characterSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String characterIssueList(int characterId, int page, int limit) =>
      "character_issue_list:$characterId:p$page:l${normalizeLimit(limit)}";

  static String creatorSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String universeSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String imprintSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String teamSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String teamIssueList(int teamId, int page, int limit) =>
      "team_issue_list:$teamId:p$page:l${normalizeLimit(limit)}";

  static String publisherSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String publisherSeriesList(int publisherId, int page, int limit) =>
      "publisher_series_list:$publisherId:p$page:l${normalizeLimit(limit)}";

  static String arcSearch(String query, int page, int limit) =>
      "${normalizeSearchQuery(query)}::p$page:l${normalizeLimit(limit)}";

  static String arcIssueList(int arcId, int page, int limit) =>
      "arc_issue_list:$arcId:p$page:l${normalizeLimit(limit)}";

  static String arcList(int page, int limit, {DateTime? modifiedGt}) =>
      "arc_list:p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}";

  static String characterList(int page, int limit, {DateTime? modifiedGt}) =>
      "character_list:p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}";

  static String creatorList(int page, int limit, {DateTime? modifiedGt}) =>
      "creator_list:p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}";

  static String imprintList(int page, int limit, {DateTime? modifiedGt}) =>
      "imprint_list:p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}";

  static String publisherList(int page, int limit, {DateTime? modifiedGt}) =>
      "publisher_list:p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}";

  static String teamList(int page, int limit, {DateTime? modifiedGt}) =>
      "team_list:p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}";

  static String universeList(int page, int limit, {DateTime? modifiedGt}) =>
      "universe_list:p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}";

  static String readingList(
    int page,
    int limit, {
    DateTime? modifiedGt,
    String? name,
    String? listType,
    String? attributionSource,
    String? publisher,
  }) =>
      'reading_list:${name != null ? '${normalizeSearchQuery(name)}::' : ''}'
      "p$page:l${normalizeLimit(limit)}:m${normalizeModifiedGt(modifiedGt)}"
      ':lt${(listType ?? '').trim().toLowerCase()}'
      ':as${(attributionSource ?? '').trim().toLowerCase()}'
      ':pu${(publisher ?? '').trim().toLowerCase()}';
}
