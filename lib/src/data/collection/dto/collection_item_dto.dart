import "package:takion/src/domain/collection/entities/collection_item.dart";

class CollectionReadDateDto {
  const CollectionReadDateDto({
    required this.id,
    required this.readDate,
    this.createdOn,
  });

  final int id;
  final String readDate;
  final String? createdOn;

  factory CollectionReadDateDto.fromJson(Map<String, dynamic> json) {
    return CollectionReadDateDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      readDate: json["read_date"] as String? ?? "",
      createdOn: json["created_on"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "read_date": readDate,
    if (createdOn != null) "created_on": createdOn,
  };

  CollectionReadDate toEntity() {
    return CollectionReadDate(
      id: id,
      readDate: DateTime.tryParse(readDate) ?? DateTime.now(),
      createdOn: createdOn != null ? DateTime.tryParse(createdOn!) : null,
    );
  }
}

class CollectionItemDto {
  const CollectionItemDto({
    required this.id,
    required this.issueId,
    required this.seriesId,
    required this.seriesName,
    required this.issueNumber,
    this.seriesVolume,
    this.seriesYearBegan,
    this.coverDate,
    this.storeDate,
    this.quantity = 1,
    this.bookFormat = "PRINT",
    this.grade,
    this.gradingCompany,
    this.purchaseDate,
    this.purchasePrice,
    this.purchasePriceCurrency = "USD",
    this.purchaseStore,
    this.storageLocation,
    this.notes,
    this.isRead = false,
    this.readDates = const [],
    this.readCount = 0,
    this.rating,
    this.modified,
  });

  final int id;
  final int issueId;
  final int seriesId;
  final String seriesName;
  final String issueNumber;
  final int? seriesVolume;
  final int? seriesYearBegan;
  final String? coverDate;
  final String? storeDate;
  final int quantity;
  final String bookFormat;
  final double? grade;
  final String? gradingCompany;
  final String? purchaseDate;
  final double? purchasePrice;
  final String purchasePriceCurrency;
  final String? purchaseStore;
  final String? storageLocation;
  final String? notes;
  final bool isRead;
  final List<CollectionReadDateDto> readDates;
  final int readCount;
  final int? rating;
  final String? modified;

  factory CollectionItemDto.fromJson(Map<String, dynamic> json) {
    final issueMap = json["issue"] as Map<String, dynamic>? ?? {};
    final seriesMap = issueMap["series"] as Map<String, dynamic>? ?? {};

    final readDatesJson = json["read_dates"] as List<dynamic>? ?? [];
    final readDates = readDatesJson
        .whereType<Map<String, dynamic>>()
        .map(CollectionReadDateDto.fromJson)
        .toList();

    double? parsedPrice;
    final rawPrice = json["purchase_price"];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice);
    }

    double? parsedGrade;
    final rawGrade = json["grade"];
    if (rawGrade is num) {
      parsedGrade = rawGrade.toDouble();
    } else if (rawGrade is String) {
      parsedGrade = double.tryParse(rawGrade);
    }

    return CollectionItemDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      issueId: (issueMap["id"] as num?)?.toInt() ?? (json["issue_id"] as num?)?.toInt() ?? 0,
      seriesId: (seriesMap["id"] as num?)?.toInt() ?? 0,
      seriesName: seriesMap["name"] as String? ?? "Unknown Series",
      issueNumber: issueMap["number"] as String? ?? "",
      seriesVolume: (seriesMap["volume"] as num?)?.toInt(),
      seriesYearBegan: (seriesMap["year_began"] as num?)?.toInt(),
      coverDate: issueMap["cover_date"] as String?,
      storeDate: issueMap["store_date"] as String?,
      quantity: (json["quantity"] as num?)?.toInt() ?? 1,
      bookFormat: json["book_format"] as String? ?? "PRINT",
      grade: parsedGrade,
      gradingCompany: json["grading_company"] as String?,
      purchaseDate: json["purchase_date"] as String?,
      purchasePrice: parsedPrice,
      purchasePriceCurrency: json["purchase_price_currency"] as String? ?? "USD",
      purchaseStore: json["purchase_store"] as String?,
      storageLocation: json["storage_location"] as String?,
      notes: json["notes"] as String?,
      isRead: json["is_read"] as bool? ?? false,
      readDates: readDates,
      readCount: (json["read_count"] as num?)?.toInt() ?? 0,
      rating: (json["rating"] as num?)?.toInt(),
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "issue": {
      "id": issueId,
      "number": issueNumber,
      "cover_date": coverDate,
      "store_date": storeDate,
      "series": {
        "id": seriesId,
        "name": seriesName,
        "volume": seriesVolume,
        "year_began": seriesYearBegan,
      },
    },
    "quantity": quantity,
    "book_format": bookFormat,
    "grade": grade?.toString(),
    "grading_company": gradingCompany,
    "purchase_date": purchaseDate,
    "purchase_price": purchasePrice?.toStringAsFixed(2),
    "purchase_price_currency": purchasePriceCurrency,
    "purchase_store": purchaseStore,
    "storage_location": storageLocation,
    "notes": notes,
    "is_read": isRead,
    "read_dates": readDates.map((e) => e.toJson()).toList(),
    "read_count": readCount,
    "rating": rating,
    "modified": modified,
  };

  CollectionItem toEntity() {
    return CollectionItem(
      id: id,
      issue: CollectionIssueRef(
        id: issueId,
        number: issueNumber,
        series: CollectionIssueSeriesRef(
          id: seriesId > 0 ? seriesId : null,
          name: seriesName,
          volume: seriesVolume,
          yearBegan: seriesYearBegan,
        ),
        coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
        storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
        modified: modified != null ? DateTime.tryParse(modified!) : null,
      ),
      quantity: quantity,
      bookFormat: bookFormat,
      grade: grade,
      gradingCompany: gradingCompany,
      purchaseDate: purchaseDate != null ? DateTime.tryParse(purchaseDate!) : null,
      purchasePrice: purchasePrice,
      purchasePriceCurrency: purchasePriceCurrency,
      purchaseStore: purchaseStore,
      storageLocation: storageLocation,
      notes: notes,
      isRead: isRead,
      readDates: readDates.map((e) => e.toEntity()).toList(),
      readCount: readCount,
      rating: rating,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
