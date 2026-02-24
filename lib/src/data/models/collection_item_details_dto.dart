import 'package:takion/src/data/models/collection_items_response_dto.dart';
import 'package:takion/src/domain/entities/collection_item_details.dart';

class CollectionItemDetailsDto {
  const CollectionItemDetailsDto({
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
  final CollectionUserRefDto? user;
  final CollectionIssueRefDto? issue;
  final int quantity;
  final String? bookFormat;
  final double? grade;
  final String? gradingCompany;
  final String? purchaseDate;
  final String? purchasePrice;
  final String? purchaseStore;
  final String? storageLocation;
  final String? notes;
  final bool isRead;
  final String? dateRead;
  final List<CollectionReadDateDto> readDates;
  final int readCount;
  final int? rating;
  final String? resourceUrl;
  final String? createdOn;
  final String? modified;

  factory CollectionItemDetailsDto.fromJson(Map<String, dynamic> json) {
    final rawReadDates = json['read_dates'];

    return CollectionItemDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      user: json['user'] is Map
          ? CollectionUserRefDto.fromJson(
              (json['user'] as Map).cast<String, dynamic>(),
            )
          : null,
      issue: json['issue'] is Map
          ? CollectionIssueRefDto.fromJson(
              (json['issue'] as Map).cast<String, dynamic>(),
            )
          : null,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      bookFormat: json['book_format'] as String?,
      grade: (json['grade'] as num?)?.toDouble(),
      gradingCompany: json['grading_company'] as String?,
      purchaseDate: json['purchase_date'] as String?,
      purchasePrice: json['purchase_price'] as String?,
      purchaseStore: json['purchase_store'] as String?,
      storageLocation: json['storage_location'] as String?,
      notes: json['notes'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      dateRead: json['date_read'] as String?,
      readDates: rawReadDates is List
          ? rawReadDates
            .whereType<Map>()
            .map((entry) => entry.cast<String, dynamic>())
            .map(CollectionReadDateDto.fromJson)
              .toList()
          : const [],
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt(),
      resourceUrl: json['resource_url'] as String?,
      createdOn: json['created_on'] as String?,
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'issue': issue?.toJson(),
      'quantity': quantity,
      'book_format': bookFormat,
      'grade': grade,
      'grading_company': gradingCompany,
      'purchase_date': purchaseDate,
      'purchase_price': purchasePrice,
      'purchase_store': purchaseStore,
      'storage_location': storageLocation,
      'notes': notes,
      'is_read': isRead,
      'date_read': dateRead,
      'read_dates': readDates.map((entry) => entry.toJson()).toList(),
      'read_count': readCount,
      'rating': rating,
      'resource_url': resourceUrl,
      'created_on': createdOn,
      'modified': modified,
    };
  }

  CollectionItemDetails toEntity() {
    return CollectionItemDetails(
      id: id,
      user: user?.toEntity(),
      issue: issue?.toEntity(),
      quantity: quantity,
      bookFormat: bookFormat,
      grade: grade,
      gradingCompany: gradingCompany,
      purchaseDate: purchaseDate != null ? DateTime.tryParse(purchaseDate!) : null,
      purchasePrice: purchasePrice,
      purchaseStore: purchaseStore,
      storageLocation: storageLocation,
      notes: notes,
      isRead: isRead,
      dateRead: dateRead != null ? DateTime.tryParse(dateRead!) : null,
      readDates: readDates.map((entry) => entry.toEntity()).toList(),
      readCount: readCount,
      rating: rating,
      resourceUrl: resourceUrl,
      createdOn: createdOn != null ? DateTime.tryParse(createdOn!) : null,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
