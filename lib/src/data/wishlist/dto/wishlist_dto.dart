import "package:takion/src/domain/wishlist/entities/wishlist_item.dart";

class WishListReadDto {
  const WishListReadDto({
    required this.id,
    required this.itemCount,
    this.itemsUrl,
    this.modified,
  });

  final int id;
  final int itemCount;
  final String? itemsUrl;
  final String? modified;

  factory WishListReadDto.fromJson(Map<String, dynamic> json) {
    return WishListReadDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      itemCount: (json["item_count"] as num?)?.toInt() ?? 0,
      itemsUrl: json["items_url"] as String?,
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "item_count": itemCount,
    if (itemsUrl != null) "items_url": itemsUrl,
    if (modified != null) "modified": modified,
  };
}

class WishListItemDto {
  const WishListItemDto({
    required this.id,
    required this.issueId,
    required this.seriesId,
    required this.seriesName,
    required this.issueNumber,
    this.seriesVolume,
    this.seriesYearBegan,
    this.coverDate,
    this.storeDate,
    this.imageUrl,
    this.priority = 3,
    this.desiredGrade,
    this.maxPrice,
    this.maxPriceCurrency = "USD",
    this.notes,
    this.addedOn,
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
  final String? imageUrl;
  final int priority;
  final double? desiredGrade;
  final double? maxPrice;
  final String maxPriceCurrency;
  final String? notes;
  final String? addedOn;
  final String? modified;

  factory WishListItemDto.fromJson(Map<String, dynamic> json) {
    final issueMap = json["issue"] as Map<String, dynamic>? ?? {};
    final seriesMap = issueMap["series"] as Map<String, dynamic>? ?? {};

    double? parsedMaxPrice;
    final rawMaxPrice = json["max_price"];
    if (rawMaxPrice is num) {
      parsedMaxPrice = rawMaxPrice.toDouble();
    } else if (rawMaxPrice is String) {
      parsedMaxPrice = double.tryParse(rawMaxPrice);
    }

    double? parsedGrade;
    final rawGrade = json["desired_grade"];
    if (rawGrade is num) {
      parsedGrade = rawGrade.toDouble();
    } else if (rawGrade is String) {
      parsedGrade = double.tryParse(rawGrade);
    }

    return WishListItemDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      issueId: (issueMap["id"] as num?)?.toInt() ?? (json["issue_id"] as num?)?.toInt() ?? 0,
      seriesId: (seriesMap["id"] as num?)?.toInt() ?? 0,
      seriesName: seriesMap["name"] as String? ?? "Unknown Series",
      issueNumber: issueMap["number"] as String? ?? "",
      seriesVolume: (seriesMap["volume"] as num?)?.toInt(),
      seriesYearBegan: (seriesMap["year_began"] as num?)?.toInt(),
      coverDate: issueMap["cover_date"] as String?,
      storeDate: issueMap["store_date"] as String?,
      imageUrl: issueMap["image"] as String?,
      priority: (json["priority"] as num?)?.toInt() ?? 3,
      desiredGrade: parsedGrade,
      maxPrice: parsedMaxPrice,
      maxPriceCurrency: json["max_price_currency"] as String? ?? "USD",
      notes: json["notes"] as String?,
      addedOn: json["added_on"] as String?,
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
      "image": imageUrl,
      "series": {
        "id": seriesId,
        "name": seriesName,
        "volume": seriesVolume,
        "year_began": seriesYearBegan,
      },
    },
    "priority": priority,
    if (desiredGrade != null) "desired_grade": desiredGrade?.toString(),
    if (maxPrice != null) "max_price": maxPrice?.toStringAsFixed(2),
    "max_price_currency": maxPriceCurrency,
    if (notes != null) "notes": notes,
    if (addedOn != null) "added_on": addedOn,
    if (modified != null) "modified": modified,
  };

  WishlistItem toEntity() {
    return WishlistItem(
      id: id,
      issueId: issueId,
      seriesId: seriesId,
      seriesName: seriesName,
      issueNumber: issueNumber,
      seriesVolume: seriesVolume,
      seriesYearBegan: seriesYearBegan,
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      imageUrl: imageUrl,
      priority: priority,
      desiredGrade: desiredGrade,
      maxPrice: maxPrice,
      maxPriceCurrency: maxPriceCurrency,
      notes: notes,
      addedOn: addedOn != null ? DateTime.tryParse(addedOn!) : null,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}

class WishListAddItemDto {
  const WishListAddItemDto({
    required this.issueId,
    this.priority = 3,
    this.desiredGrade,
    this.maxPrice,
    this.maxPriceCurrency = "USD",
    this.notes,
  });

  final int issueId;
  final int priority;
  final double? desiredGrade;
  final double? maxPrice;
  final String maxPriceCurrency;
  final String? notes;

  Map<String, dynamic> toJson() => {
    "issue_id": issueId,
    "priority": priority,
    if (desiredGrade != null) "desired_grade": desiredGrade?.toString(),
    if (maxPrice != null) "max_price": maxPrice?.toStringAsFixed(2),
    "max_price_currency": maxPriceCurrency,
    if (notes != null) "notes": notes,
  };
}

class AcquireWishListItemDto {
  const AcquireWishListItemDto({
    this.purchaseDate,
    this.purchasePrice,
    this.purchasePriceCurrency = "USD",
    this.purchaseStore,
    this.notes,
  });

  final String? purchaseDate;
  final double? purchasePrice;
  final String purchasePriceCurrency;
  final String? purchaseStore;
  final String? notes;

  Map<String, dynamic> toJson() => {
    if (purchaseDate != null) "purchase_date": purchaseDate,
    if (purchasePrice != null) "purchase_price": purchasePrice?.toStringAsFixed(2),
    "purchase_price_currency": purchasePriceCurrency,
    if (purchaseStore != null) "purchase_store": purchaseStore,
    if (notes != null) "notes": notes,
  };
}
