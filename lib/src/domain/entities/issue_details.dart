import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue_details.freezed.dart';

@freezed
abstract class IssueDetails with _$IssueDetails {
  const factory IssueDetails({
    required int id,
    IssueDetailsNamedRef? publisher,
    IssueDetailsNamedRef? imprint,
    IssueDetailsSeries? series,
    required String number,
    String? altNumber,
    String? title,
    @Default(<String>[]) List<String> names,
    DateTime? coverDate,
    DateTime? storeDate,
    DateTime? focDate,
    String? price,
    String? priceCurrency,
    IssueDetailsNamedRef? rating,
    String? sku,
    String? isbn,
    String? upc,
    int? page,
    String? description,
    String? image,
    String? coverHash,
    @Default(<IssueDetailsParticipation>[]) List<IssueDetailsParticipation> arcs,
    @Default(<IssueDetailsCredit>[]) List<IssueDetailsCredit> credits,
    @Default(<IssueDetailsParticipation>[]) List<IssueDetailsParticipation> characters,
    @Default(<IssueDetailsParticipation>[]) List<IssueDetailsParticipation> teams,
    @Default(<IssueDetailsParticipation>[]) List<IssueDetailsParticipation> universes,
    @Default(<IssueDetailsReprint>[]) List<IssueDetailsReprint> reprints,
    @Default(<IssueDetailsVariant>[]) List<IssueDetailsVariant> variants,
    int? cvId,
    int? gcdId,
    String? resourceUrl,
    DateTime? modified,
  }) = _IssueDetails;
}

@freezed
abstract class IssueDetailsNamedRef with _$IssueDetailsNamedRef {
  const factory IssueDetailsNamedRef({required int id, required String name}) =
      _IssueDetailsNamedRef;
}

@freezed
abstract class IssueDetailsSeries with _$IssueDetailsSeries {
  const factory IssueDetailsSeries({
    required int id,
    required String name,
    String? sortName,
    int? volume,
    int? yearBegan,
    IssueDetailsNamedRef? seriesType,
    @Default(<IssueDetailsNamedRef>[]) List<IssueDetailsNamedRef> genres,
  }) = _IssueDetailsSeries;
}

@freezed
abstract class IssueDetailsParticipation with _$IssueDetailsParticipation {
  const factory IssueDetailsParticipation({
    required int id,
    required String name,
    DateTime? modified,
  }) = _IssueDetailsParticipation;
}

@freezed
abstract class IssueDetailsCreditRole with _$IssueDetailsCreditRole {
  const factory IssueDetailsCreditRole({required int id, required String name}) =
      _IssueDetailsCreditRole;
}

@freezed
abstract class IssueDetailsCredit with _$IssueDetailsCredit {
  const factory IssueDetailsCredit({
    required int id,
    String? creator,
    @Default(<IssueDetailsCreditRole>[]) List<IssueDetailsCreditRole> roles,
  }) = _IssueDetailsCredit;
}

@freezed
abstract class IssueDetailsReprint with _$IssueDetailsReprint {
  const factory IssueDetailsReprint({required int id, String? issue}) =
      _IssueDetailsReprint;
}

@freezed
abstract class IssueDetailsVariant with _$IssueDetailsVariant {
  const factory IssueDetailsVariant({
    String? name,
    String? price,
    String? sku,
    String? upc,
    String? image,
  }) = _IssueDetailsVariant;
}
