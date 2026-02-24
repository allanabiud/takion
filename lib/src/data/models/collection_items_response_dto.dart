import 'package:takion/src/domain/entities/collection_item.dart';

class CollectionUserRefDto {
  const CollectionUserRefDto({
    required this.id,
    required this.username,
  });

  final int id;
  final String username;

  factory CollectionUserRefDto.fromJson(Map<String, dynamic> json) {
    return CollectionUserRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }

  CollectionUserRef toEntity() => CollectionUserRef(id: id, username: username);
}

class CollectionIssueSeriesRefDto {
  const CollectionIssueSeriesRefDto({
    required this.name,
    this.volume,
    this.yearBegan,
  });

  final String name;
  final int? volume;
  final int? yearBegan;

  factory CollectionIssueSeriesRefDto.fromJson(Map<String, dynamic> json) {
    return CollectionIssueSeriesRefDto(
      name: (json['name'] as String?) ?? '',
      volume: (json['volume'] as num?)?.toInt(),
      yearBegan: (json['year_began'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'volume': volume,
      'year_began': yearBegan,
    };
  }

  CollectionIssueSeriesRef toEntity() {
    return CollectionIssueSeriesRef(
      name: name,
      volume: volume,
      yearBegan: yearBegan,
    );
  }
}

class CollectionIssueRefDto {
  const CollectionIssueRefDto({
    required this.id,
    required this.number,
    this.series,
    this.coverDate,
    this.storeDate,
    this.modified,
  });

  final int id;
  final String number;
  final CollectionIssueSeriesRefDto? series;
  final String? coverDate;
  final String? storeDate;
  final String? modified;

  factory CollectionIssueRefDto.fromJson(Map<String, dynamic> json) {
    return CollectionIssueRefDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      number: (json['number'] as String?) ?? '',
      series: json['series'] is Map
          ? CollectionIssueSeriesRefDto.fromJson(
              (json['series'] as Map).cast<String, dynamic>(),
            )
          : null,
      coverDate: json['cover_date'] as String?,
      storeDate: json['store_date'] as String?,
      modified: json['modified'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'series': series?.toJson(),
      'cover_date': coverDate,
      'store_date': storeDate,
      'modified': modified,
    };
  }

  CollectionIssueRef toEntity() {
    return CollectionIssueRef(
      id: id,
      number: number,
      series: series?.toEntity(),
      coverDate: coverDate != null ? DateTime.tryParse(coverDate!) : null,
      storeDate: storeDate != null ? DateTime.tryParse(storeDate!) : null,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}

class CollectionReadDateDto {
  const CollectionReadDateDto({
    required this.id,
    this.readDate,
    this.createdOn,
  });

  final int id;
  final String? readDate;
  final String? createdOn;

  factory CollectionReadDateDto.fromJson(Map<String, dynamic> json) {
    return CollectionReadDateDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      readDate: json['read_date'] as String?,
      createdOn: json['created_on'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'read_date': readDate,
      'created_on': createdOn,
    };
  }

  CollectionReadDate toEntity() {
    return CollectionReadDate(
      id: id,
      readDate: readDate != null ? DateTime.tryParse(readDate!) : null,
      createdOn: createdOn != null ? DateTime.tryParse(createdOn!) : null,
    );
  }
}

class CollectionItemDto {
  const CollectionItemDto({
    required this.id,
    this.user,
    this.issue,
    required this.quantity,
    this.bookFormat,
    this.grade,
    this.gradingCompany,
    this.purchaseDate,
    required this.isRead,
    this.readDates = const [],
    required this.readCount,
    this.rating,
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
  final bool isRead;
  final List<CollectionReadDateDto> readDates;
  final int readCount;
  final int? rating;
  final String? modified;

  factory CollectionItemDto.fromJson(Map<String, dynamic> json) {
    final rawReadDates = json['read_dates'];

    return CollectionItemDto(
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
      isRead: json['is_read'] as bool? ?? false,
      readDates: rawReadDates is List
          ? rawReadDates
            .whereType<Map>()
            .map((entry) => entry.cast<String, dynamic>())
            .map(CollectionReadDateDto.fromJson)
              .toList()
          : const [],
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt(),
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
      'is_read': isRead,
      'read_dates': readDates.map((entry) => entry.toJson()).toList(),
      'read_count': readCount,
      'rating': rating,
      'modified': modified,
    };
  }

  CollectionItem toEntity() {
    return CollectionItem(
      id: id,
      user: user?.toEntity(),
      issue: issue?.toEntity(),
      quantity: quantity,
      bookFormat: bookFormat,
      grade: grade,
      gradingCompany: gradingCompany,
      purchaseDate: purchaseDate != null ? DateTime.tryParse(purchaseDate!) : null,
      isRead: isRead,
      readDates: readDates.map((entry) => entry.toEntity()).toList(),
      readCount: readCount,
      rating: rating,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}

class CollectionItemsResponseDto {
  const CollectionItemsResponseDto({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<CollectionItemDto> results;

  factory CollectionItemsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final results = rawResults is List
        ? rawResults
        .whereType<Map>()
        .map((entry) => entry.cast<String, dynamic>())
        .map(CollectionItemDto.fromJson)
            .toList()
        : <CollectionItemDto>[];

    return CollectionItemsResponseDto(
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((entry) => entry.toJson()).toList(),
    };
  }
}
