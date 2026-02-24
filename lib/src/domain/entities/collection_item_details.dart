import 'package:takion/src/domain/entities/collection_item.dart';

class CollectionItemDetails {
  const CollectionItemDetails({
    required this.id,
    this.user,
    this.issue,
    required this.quantity,
    this.bookFormat,
    this.grade,
    this.gradingCompany,
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseStore,
    this.storageLocation,
    this.notes,
    required this.isRead,
    this.dateRead,
    this.readDates = const [],
    required this.readCount,
    this.rating,
    this.resourceUrl,
    this.createdOn,
    this.modified,
  });

  final int id;
  final CollectionUserRef? user;
  final CollectionIssueRef? issue;
  final int quantity;
  final String? bookFormat;
  final double? grade;
  final String? gradingCompany;
  final DateTime? purchaseDate;
  final String? purchasePrice;
  final String? purchaseStore;
  final String? storageLocation;
  final String? notes;
  final bool isRead;
  final DateTime? dateRead;
  final List<CollectionReadDate> readDates;
  final int readCount;
  final int? rating;
  final String? resourceUrl;
  final DateTime? createdOn;
  final DateTime? modified;
}
