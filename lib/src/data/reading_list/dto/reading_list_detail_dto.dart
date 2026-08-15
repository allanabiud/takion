import "package:takion/src/domain/entities.dart";

class ReadingListDetailDto {
  const ReadingListDetailDto({
    required this.id,
    required this.name,
    this.slug,
    this.desc,
    this.image,
    this.listType,
    this.isPrivate,
    this.attributionSource,
    this.attributionUrl,
    this.averageRating,
    this.ratingCount,
    this.itemsUrl,
    this.resourceUrl,
    this.userId,
    this.username,
    this.modified,
  });

  final int id;
  final String name;
  final String? slug;
  final String? desc;
  final String? image;
  final String? listType;
  final bool? isPrivate;
  final String? attributionSource;
  final String? attributionUrl;
  final double? averageRating;
  final int? ratingCount;
  final String? itemsUrl;
  final String? resourceUrl;
  final int? userId;
  final String? username;
  final String? modified;

  factory ReadingListDetailDto.fromJson(Map<String, dynamic> json) {
    final user = json["user"] as Map<String, dynamic>?;

    return ReadingListDetailDto(
      id: (json["id"] as num?)?.toInt() ?? 0,
      name: (json["name"] as String?)?.trim().isNotEmpty == true
          ? (json["name"] as String)
          : "Unknown List",
      slug: json["slug"] as String?,
      desc: json["desc"] as String?,
      image: json["image"] as String?,
      listType: json["list_type"] as String?,
      isPrivate: json["is_private"] as bool?,
      attributionSource: json["attribution_source"] as String?,
      attributionUrl: json["attribution_url"] as String?,
      averageRating: (json["average_rating"] as num?)?.toDouble(),
      ratingCount: (json["rating_count"] as num?)?.toInt(),
      itemsUrl: json["items_url"] as String?,
      resourceUrl: json["resource_url"] as String?,
      userId: (user?["id"] as num?)?.toInt(),
      username: user?["username"] as String?,
      modified: json["modified"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "desc": desc,
    "image": image,
    "list_type": listType,
    "is_private": isPrivate,
    "attribution_source": attributionSource,
    "attribution_url": attributionUrl,
    "average_rating": averageRating,
    "rating_count": ratingCount,
    "items_url": itemsUrl,
    "resource_url": resourceUrl,
    "user": userId != null ? {"id": userId, "username": username} : null,
    "modified": modified,
  };

  MetronReadingListDetail toEntity() {
    return MetronReadingListDetail(
      id: id,
      name: name,
      slug: slug,
      desc: desc,
      image: image,
      listType: listType,
      isPrivate: isPrivate ?? false,
      attributionSource: attributionSource,
      attributionUrl: attributionUrl,
      averageRating: averageRating,
      ratingCount: ratingCount ?? 0,
      itemsUrl: itemsUrl,
      resourceUrl: resourceUrl,
      userId: userId,
      username: username,
      modified: modified != null ? DateTime.tryParse(modified!) : null,
    );
  }
}
