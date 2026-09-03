import "package:takion/src/domain/collection/entities/library_item.dart";

enum CollectionBookFormat {
  print,
  digital,
  both;

  static CollectionBookFormat fromString(String? value) {
    switch (value?.toUpperCase()) {
      case "DIGITAL":
        return CollectionBookFormat.digital;
      case "BOTH":
        return CollectionBookFormat.both;
      case "PRINT":
      default:
        return CollectionBookFormat.print;
    }
  }

  String toApiValue() {
    switch (this) {
      case CollectionBookFormat.digital:
        return "DIGITAL";
      case CollectionBookFormat.both:
        return "BOTH";
      case CollectionBookFormat.print:
        return "PRINT";
    }
  }
}

class CollectionUserRef {
  const CollectionUserRef({required this.id, required this.username});

  final int id;
  final String username;
}

class CollectionIssueSeriesRef {
  const CollectionIssueSeriesRef({
    this.id,
    required this.name,
    this.volume,
    this.yearBegan,
  });

  final int? id;
  final String name;
  final int? volume;
  final int? yearBegan;
}

class CollectionIssueRef {
  const CollectionIssueRef({
    required this.id,
    required this.number,
    this.series,
    this.image,
    this.coverDate,
    this.storeDate,
    this.modified,
  });

  final int id;
  final String number;
  final CollectionIssueSeriesRef? series;
  final String? image;
  final DateTime? coverDate;
  final DateTime? storeDate;
  final DateTime? modified;
}

class CollectionReadDate {
  const CollectionReadDate({
    required this.id,
    this.readDate,
    this.createdOn,
  });

  final int id;
  final DateTime? readDate;
  final DateTime? createdOn;
}

class CollectionItem {
  const CollectionItem({
    required this.id,
    this.user,
    this.issue,
    this.quantity = 1,
    this.bookFormat,
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
    this.ownershipStatus,
    this.pricePaid,
    this.firstReadAt,
    this.acquiredOn,
    this.syncStatus = "synced",
  });

  final int id;
  final CollectionUserRef? user;
  final CollectionIssueRef? issue;
  final int quantity;
  final String? bookFormat;
  final double? grade;
  final String? gradingCompany;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String purchasePriceCurrency;
  final String? purchaseStore;
  final String? storageLocation;
  final String? notes;
  final bool isRead;
  final List<CollectionReadDate> readDates;
  final int readCount;
  final int? rating;
  final DateTime? modified;
  final LibraryOwnershipStatus? ownershipStatus;
  final double? pricePaid;
  final DateTime? firstReadAt;
  final DateTime? acquiredOn;
  final String syncStatus;

  int get issueId => issue?.id ?? 0;
  String get issueNumber => issue?.number ?? "";
  int get seriesId => issue?.series?.id ?? 0;
  String get seriesName => issue?.series?.name ?? "";
  int? get seriesVolume => issue?.series?.volume;
  int? get seriesYearBegan => issue?.series?.yearBegan;
  String? get imageUrl => issue?.image;
  DateTime? get coverDate => issue?.coverDate;
  DateTime? get storeDate => issue?.storeDate;

  CollectionItem copyWith({
    int? id,
    CollectionUserRef? user,
    CollectionIssueRef? issue,
    int? quantity,
    String? bookFormat,
    double? grade,
    String? gradingCompany,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? purchasePriceCurrency,
    String? purchaseStore,
    String? storageLocation,
    String? notes,
    bool? isRead,
    List<CollectionReadDate>? readDates,
    int? readCount,
    int? rating,
    DateTime? modified,
    LibraryOwnershipStatus? ownershipStatus,
    double? pricePaid,
    DateTime? firstReadAt,
    DateTime? acquiredOn,
    String? syncStatus,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      user: user ?? this.user,
      issue: issue ?? this.issue,
      quantity: quantity ?? this.quantity,
      bookFormat: bookFormat ?? this.bookFormat,
      grade: grade ?? this.grade,
      gradingCompany: gradingCompany ?? this.gradingCompany,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchasePriceCurrency:
          purchasePriceCurrency ?? this.purchasePriceCurrency,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      storageLocation: storageLocation ?? this.storageLocation,
      notes: notes ?? this.notes,
      isRead: isRead ?? this.isRead,
      readDates: readDates ?? this.readDates,
      readCount: readCount ?? this.readCount,
      rating: rating ?? this.rating,
      modified: modified ?? this.modified,
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      pricePaid: pricePaid ?? this.pricePaid,
      firstReadAt: firstReadAt ?? this.firstReadAt,
      acquiredOn: acquiredOn ?? this.acquiredOn,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
