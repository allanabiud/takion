class CollectionUserRef {
  const CollectionUserRef({
    required this.id,
    required this.username,
  });

  final int id;
  final String username;
}

class CollectionIssueSeriesRef {
  const CollectionIssueSeriesRef({
    required this.name,
    this.volume,
    this.yearBegan,
  });

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
  final CollectionUserRef? user;
  final CollectionIssueRef? issue;
  final int quantity;
  final String? bookFormat;
  final double? grade;
  final String? gradingCompany;
  final DateTime? purchaseDate;
  final bool isRead;
  final List<CollectionReadDate> readDates;
  final int readCount;
  final int? rating;
  final DateTime? modified;
}
