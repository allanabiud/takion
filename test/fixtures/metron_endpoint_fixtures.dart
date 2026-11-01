/// Endpoint contract fixtures matching `assets/docs/Metron/Metron Comicbook Database.yaml`.
///
/// These realistic JSON fixtures represent actual wire responses from the Metron
/// REST API v1 endpoints for collections, pull lists, wishlists, and catalog entities.
abstract final class MetronEndpointFixtures {
  /// GET /api/collection/
  static const Map<String, dynamic> collectionList = {
    "count": 2,
    "next": "https://metron.cloud/api/collection/?page=2",
    "previous": null,
    "results": [
      {
        "id": 101,
        "user": "comic_collector",
        "issue": {
          "id": 2001,
          "number": "1",
          "cover_date": "2020-03-01",
          "store_date": "2020-03-04",
          "image": "https://metron.cloud/media/issue/2001.jpg",
          "series": {
            "id": 301,
            "name": "Batman",
            "volume": 3,
            "year_began": 2016,
          },
        },
        "quantity": 1,
        "book_format": "PRINT",
        "grade": 9.8,
        "grading_company": "CGC",
        "purchase_date": "2020-03-05",
        "purchase_price": "3.99",
        "purchase_price_currency": "USD",
        "purchase_store": "Gotham Comics",
        "storage_location": "Box A",
        "notes": "First printing variant A",
        "is_read": true,
        "rating": 5,
        "signed": false,
        "created_on": "2026-01-01T00:00:00Z",
        "modified": "2026-01-02T00:00:00Z",
        "read_dates": [
          {
            "id": 1,
            "read_date": "2020-03-10",
            "created_on": "2020-03-10T00:00:00Z",
          },
        ],
      },
      {
        "id": 102,
        "user": "comic_collector",
        "issue": {
          "id": 2002,
          "number": "2",
          "cover_date": "2020-04-01",
          "store_date": "2020-04-01",
          "series": {
            "id": 301,
            "name": "Batman",
            "volume": 3,
            "year_began": 2016,
          },
        },
        "quantity": 1,
        "book_format": "DIGITAL",
        "is_read": false,
        "rating": null,
        "created_on": "2026-01-03T00:00:00Z",
        "modified": "2026-01-03T00:00:00Z",
      },
    ],
  };

  /// POST /api/collection/add/
  static const Map<String, dynamic> collectionAddResponse = {
    "id": 103,
    "user": "comic_collector",
    "issue": {
      "id": 2003,
      "number": "3",
      "series": {"id": 301, "name": "Batman", "volume": 3, "year_began": 2016},
    },
    "quantity": 1,
    "book_format": "PRINT",
    "is_read": false,
    "created_on": "2026-10-26T12:00:00Z",
    "modified": "2026-10-26T12:00:00Z",
  };

  /// POST /api/collection/scrobble/
  static const Map<String, dynamic> scrobbleResponse = {
    "id": 101,
    "is_read": true,
    "date_read": "2026-10-26",
    "modified": "2026-10-26T12:00:00Z",
  };

  /// GET /api/pull_list/
  static const Map<String, dynamic> pullListSummary = {
    "id": 50,
    "series_count": 1,
    "series_url": "https://metron.cloud/api/pull_list/series/",
    "modified": "2026-10-20T10:00:00Z",
  };

  /// GET /api/pull_list/series/
  static const Map<String, dynamic> pullListSeries = {
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
      {
        "id": 701,
        "series": {
          "id": 301,
          "name": "Batman",
          "volume": 3,
          "year_began": 2016,
          "publisher": {"id": 1, "name": "DC Comics"},
        },
        "added_on": "2026-01-15T00:00:00Z",
      },
    ],
  };

  /// GET /api/pull_list/issues/
  static const Map<String, dynamic> pullListIssues = {
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
      {
        "id": 2050,
        "number": "50",
        "name": "The Wedding",
        "cover_date": "2026-11-01",
        "store_date": "2026-11-05",
        "image": "https://metron.cloud/media/issue/2050.jpg",
        "series": {"id": 301, "name": "Batman"},
        "added_on": "2026-10-01T00:00:00Z",
      },
    ],
  };

  /// GET /api/wish_list/
  static const Map<String, dynamic> wishListSummary = {
    "id": 60,
    "item_count": 1,
    "items_url": "https://metron.cloud/api/wish_list/items/",
    "modified": "2026-10-22T08:00:00Z",
  };

  /// GET /api/wish_list/items/
  static const Map<String, dynamic> wishListItems = {
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
      {
        "id": 901,
        "issue": {
          "id": 2005,
          "number": "5",
          "cover_date": "2020-07-01",
          "store_date": "2020-07-08",
          "image": "https://metron.cloud/media/issue/2005.jpg",
          "series": {
            "id": 301,
            "name": "Batman",
            "volume": 3,
            "year_began": 2016,
          },
        },
        "priority": 4,
        "desired_grade": "9.6",
        "max_price": "25.00",
        "max_price_currency": "USD",
        "notes": "Variant cover wanted",
        "added_on": "2026-02-01T00:00:00Z",
        "modified": "2026-02-01T00:00:00Z",
      },
    ],
  };

  /// GET /api/issue/{id}/
  static const Map<String, dynamic> issueDetail = {
    "id": 2001,
    "number": "1",
    "name": ["I Am Gotham: Part One"],
    "cover_date": "2020-03-01",
    "store_date": "2020-03-04",
    "price": "3.99",
    "sku": "DEC190520",
    "upc": "76194134182800111",
    "page": 32,
    "desc": "No one ever said saving Gotham City would be easy.",
    "image": "https://metron.cloud/media/issue/2001.jpg",
    "series": {"id": 301, "name": "Batman", "volume": 3, "year_began": 2016},
    "publisher": {"id": 1, "name": "DC Comics"},
    "arcs": [
      {"id": 10, "name": "I Am Gotham"},
    ],
    "credits": [
      {
        "id": 501,
        "creator": "Tom King",
        "role": [
          {"id": 1, "name": "Writer"},
        ],
      },
      {
        "id": 502,
        "creator": "David Finch",
        "role": [
          {"id": 2, "name": "Penciller"},
          {"id": 3, "name": "Inker"},
        ],
      },
    ],
    "characters": [
      {"id": 1, "name": "Batman (Bruce Wayne)"},
    ],
    "teams": [
      {"id": 2, "name": "Batman Family"},
    ],
    "modified": "2026-10-25T14:30:00Z",
  };
}
