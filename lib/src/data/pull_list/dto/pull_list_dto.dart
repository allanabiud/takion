import "package:takion/src/domain/pull_list/entities/pull_list_item.dart";

class PullListReadDto {
  const PullListReadDto({
    required this.id,
    required this.seriesCount,
    this.seriesUrl,
    this.modified,
  });

  final int id;
  final int seriesCount;
  final String? seriesUrl;
  final String? modified;

  factory PullListReadDto.fromJson(Map<String, dynamic> json) {
    return PullListReadDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      seriesCount: (json["series_count"] as num?)?.toInt() ?? 0,
      seriesUrl: json["series_url"] as String?,
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "series_count": seriesCount,
    if (seriesUrl != null) "series_url": seriesUrl,
    if (modified != null) "modified": modified,
  };
}

class PullListSeriesDto {
  const PullListSeriesDto({
    required this.id,
    required this.seriesId,
    required this.seriesName,
    this.volume,
    this.yearBegan,
    this.publisherName,
    this.imageUrl,
    this.addedOn,
  });

  final int id;
  final int seriesId;
  final String seriesName;
  final int? volume;
  final int? yearBegan;
  final String? publisherName;
  final String? imageUrl;
  final String? addedOn;

  factory PullListSeriesDto.fromJson(Map<String, dynamic> json) {
    final seriesMap = json["series"] as Map<String, dynamic>? ?? {};
    final publisherMap = seriesMap["publisher"] as Map<String, dynamic>? ?? {};

    return PullListSeriesDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      seriesId: (seriesMap["id"] as num?)?.toInt() ?? (json["series_id"] as num?)?.toInt() ?? 0,
      seriesName: seriesMap["name"] as String? ?? "Unknown Series",
      volume: (seriesMap["volume"] as num?)?.toInt(),
      yearBegan: (seriesMap["year_began"] as num?)?.toInt(),
      publisherName: publisherMap["name"] as String? ?? seriesMap["publisher_name"] as String?,
      imageUrl: (seriesMap["image"] as String?) ?? (seriesMap["resource_url"] as String?),
      addedOn: json["added_on"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "series": {
      "id": seriesId,
      "name": seriesName,
      if (volume != null) "volume": volume,
      if (yearBegan != null) "year_began": yearBegan,
      if (publisherName != null) "publisher": {"name": publisherName},
      if (imageUrl != null) "image": imageUrl,
    },
    if (addedOn != null) "added_on": addedOn,
  };

  PullListSeriesItem toEntity() {
    return PullListSeriesItem(
      id: id,
      seriesId: seriesId,
      seriesName: seriesName,
      volume: volume,
      yearBegan: yearBegan,
      publisherName: publisherName,
      imageUrl: imageUrl,
      addedOn: addedOn != null ? DateTime.tryParse(addedOn!) : null,
    );
  }
}

class PullListIssueDto {
  const PullListIssueDto({
    required this.id,
    required this.issueId,
    required this.seriesId,
    required this.seriesName,
    required this.issueNumber,
    this.coverDate,
    this.storeDate,
    this.imageUrl,
    this.price,
    this.modified,
  });

  final int id;
  final int issueId;
  final int seriesId;
  final String seriesName;
  final String issueNumber;
  final String? coverDate;
  final String? storeDate;
  final String? imageUrl;
  final double? price;
  final String? modified;

  factory PullListIssueDto.fromJson(Map<String, dynamic> json) {
    final seriesMap = json["series"] as Map<String, dynamic>? ?? {};

    double? parsedPrice;
    final rawPrice = json["price"];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice);
    }

    return PullListIssueDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      issueId: (json["issue_id"] as num?)?.toInt() ?? (json["id"] as num?)?.toInt() ?? 0,
      seriesId: (seriesMap["id"] as num?)?.toInt() ?? 0,
      seriesName: seriesMap["name"] as String? ?? "Unknown Series",
      issueNumber: json["number"] as String? ?? "",
      coverDate: json["cover_date"] as String?,
      storeDate: json["store_date"] as String?,
      imageUrl: json["image"] as String?,
      price: parsedPrice,
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "number": issueNumber,
    "series": {
      "id": seriesId,
      "name": seriesName,
    },
    if (coverDate != null) "cover_date": coverDate,
    if (storeDate != null) "store_date": storeDate,
    if (imageUrl != null) "image": imageUrl,
    if (price != null) "price": price?.toStringAsFixed(2),
    if (modified != null) "modified": modified,
  };

  PullListIssueItem toEntity() {
    return PullListIssueItem(
      id: id,
      issueId: issueId,
      seriesId: seriesId,
      seriesName: seriesName,
      issueNumber: issueNumber,
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      imageUrl: imageUrl,
      price: price,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
