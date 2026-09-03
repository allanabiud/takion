# Metron API Endpoints

Reference for the Metron API endpoints. All endpoints live under `https://metron.cloud`.

## Authentication

All requests require authentication. Metron supports three authentication methods:

| Method | Type | Header | Description |
|--------|------|--------|-------------|
| **Basic Auth** | HTTP Basic | `Authorization: Basic <base64>` | Username + password |
| **API Token** | Bearer Token | `Authorization: Token <token>` | Knox API token (recommended) |
| **Session Cookie** | Cookie | `Cookie: sessionid=<value>` | Browser session |

> **Tip:** API tokens (`knoxApiToken`) are the recommended method for programmatic access. They don't require sending your password with every request.

## General Notes

- Responses are paginated using the standard DRF format (`count`, `next`, `previous`, `results`).
- Read endpoints (`GET`) are open to any authenticated user.
- Write operations (create/update on imprints, publishers, series, collections) require the Editor or Admin role.
- `next` and `previous` pagination URLs are ready to use — pass them straight to your HTTP client.


## Endpoint Overview

| Endpoint | Methods | Description |
|---|---|---|
| `/api/arc/` | GET | List story arcs |
| `/api/arc/{id}/` | GET | Retrieve a story arc |
| `/api/arc/{id}/issue_list/` | GET | List issues in a story arc |
| `/api/character/` | GET | List characters |
| `/api/character/{id}/` | GET | Retrieve a character |
| `/api/character/{id}/issue_list/` | GET | List a character's appearances |
| `/api/collection/` | GET | List user's collection items |
| `/api/collection/add/` | POST | Add issue to collection |
| `/api/collection/{id}/` | GET, PUT, PATCH, DELETE | Manage collection item |
| `/api/collection/missing_issues/{series_id}/` | GET | Get missing issues for series |
| `/api/collection/missing_series/` | GET | Get series with missing issues |
| `/api/collection/scrobble/` | POST | Mark issue as read |
| `/api/collection/stats/` | GET | Collection statistics |
| `/api/creator/` | GET | List creators |
| `/api/creator/{id}/` | GET | Retrieve a creator |
| `/api/imprint/` | GET, POST | List/create imprints |
| `/api/imprint/{id}/` | GET, PUT, PATCH | Retrieve/update imprint |
| `/api/issue/` | GET | List issues |
| `/api/issue/{id}/` | GET | Retrieve an issue |
| `/api/publisher/` | GET, POST | List/create publishers |
| `/api/publisher/{id}/` | GET, PUT, PATCH | Retrieve/update publisher |
| `/api/publisher/{id}/series_list/` | GET | List a publisher's series |
| `/api/pull_list/` | GET | List pull lists |
| `/api/pull_list/{id}/` | GET | Retrieve a pull list |
| `/api/pull_list/issues/` | GET | List issues for pull list series |
| `/api/pull_list/series/` | GET | List series on pull list |
| `/api/pull_list/series/add/` | POST | Add series to pull list |
| `/api/pull_list/series/{series_pk}/remove/` | DELETE | Remove series from pull list |
| `/api/reading_list/` | GET | List reading lists |
| `/api/reading_list/{id}/` | GET | Retrieve a reading list |
| `/api/reading_list/{id}/items/` | GET | List a reading list's items |
| `/api/role/` | GET | List creator roles |
| `/api/schema/` | GET | OpenAPI schema |
| `/api/series/` | GET, POST | List/create series |
| `/api/series/{id}/` | GET, PUT, PATCH | Retrieve/update series |
| `/api/series/{id}/issue_list/` | GET | List a series' issues |
| `/api/series_type/` | GET | List series types |
| `/api/team/` | GET | List teams |
| `/api/team/{id}/` | GET | Retrieve a team |
| `/api/team/{id}/issue_list/` | GET | List issues featuring a team |
| `/api/universe/` | GET | List universes |
| `/api/universe/{id}/` | GET | Retrieve a universe |
| `/api/wish_list/` | GET | List wish lists |
| `/api/wish_list/{id}/` | GET | Retrieve a wish list |
| `/api/wish_list/items/` | GET | List wish list items |
| `/api/wish_list/items/add/` | POST | Add issue to wish list |
| `/api/wish_list/items/{item_pk}/acquire/` | POST | Mark item as acquired |
| `/api/wish_list/items/{item_pk}/remove/` | DELETE | Remove wish list item |

---


## Story Arcs

### `GET /api/arc/`

Returns a list of all the story arcs.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `cv_id` | integer | Comic Vine ID |
| `gcd_id` | integer | Grand Comics Database ID |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/arc/{id}/`

Returns the information of an individual story arc.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this arc. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "desc": "string",
  "image": "https://example.com/image.jpg",
  "cv_id": 0,
  "gcd_id": 0,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/arc/{id}/issue_list/`

Returns the list of issues in a story arc.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this arc. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---


## Characters

### `GET /api/character/`

Returns a list of all the characters.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `cv_id` | integer | Comic Vine ID |
| `gcd_id` | integer | Grand Comics Database ID |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/character/{id}/`

Returns the information of an individual character.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this character. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "alias": [
    "string"
  ],
  "desc": "string",
  "image": "https://example.com/image.jpg",
  "cv_id": 0,
  "gcd_id": 0,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/character/{id}/issue_list/`

Returns a list of a character's appearances.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this character. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---


## Collection

### `GET /api/collection/`

Returns authenticated user's collection items.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `book_format` | string | Format: PRINT, DIGITAL, or BOTH |
| `date_read` | string (date) | Date read |
| `grade` | number | CGC grade (0.5 - 10.0) |
| `grading_company` | string | CGC, CBCS, or PGX |
| `is_read` | boolean | Read status |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `page` | integer | Page number |
| `rating` | integer | User rating |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `POST /api/collection/add/`

Add an issue to the authenticated user's collection.

**Request Body**

```json
{
  "issue_id": 123,
  "quantity": 1,
  "book_format": "PRINT",
  "grade": null,
  "grading_company": "",
  "purchase_date": null,
  "purchase_price": null,
  "purchase_price_currency": "USD",
  "purchase_store": "",
  "storage_location": "",
  "notes": ""
}
```

**Response — `201 Created`**

```json
{
  "id": 0,
  "quantity": 0,
  "purchase_date": "2026-07-24",
  "purchase_price": "3.99",
  "purchase_store": "string",
  "storage_location": "string",
  "notes": "string",
  "is_read": true,
  "date_read": "2026-07-24T06:42:18.725Z",
  "resource_url": "string",
  "created_on": "2026-07-24T06:42:18.725Z",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/collection/{id}/`

Returns details of a specific collection item.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | Collection item ID |

**Response — `200 OK`**

```json
{
  "id": 0,
  "quantity": 0,
  "purchase_date": "2026-07-24",
  "purchase_price": "3.99",
  "purchase_store": "string",
  "storage_location": "string",
  "notes": "string",
  "is_read": true,
  "date_read": "2026-07-24T06:42:18.725Z",
  "resource_url": "string",
  "created_on": "2026-07-24T06:42:18.725Z",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `PUT /api/collection/{id}/`

Update a collection item (full update).

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | Collection item ID |

**Request Body**

```json
{
  "rating": 5
}
```

**Response — `200 OK`**

```json
{
  "id": 0,
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `PATCH /api/collection/{id}/`

Update a collection item (partial update).

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | Collection item ID |

**Request Body**

```json
{
  "rating": 5
}
```

**Response — `200 OK`**

```json
{
  "id": 0,
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `DELETE /api/collection/{id}/`

Remove an item from the collection.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | Collection item ID |

**Response — `204 No Content`**

---

### `GET /api/collection/missing_issues/{series_id}/`

Returns missing issues for a specific series.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `series_id` | integer (path) | Series ID |
| `page` | integer | Page number |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/collection/missing_series/`

Returns series where the user has some issues but is missing others.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `page` | integer | Page number |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `POST /api/collection/scrobble/`

Mark an issue as read (scrobble). Auto-creates collection item if needed.

**Request Body**

```json
{
  "issue_id": 123,
  "date_read": "2026-09-03T00:00:00Z",
  "rating": 5
}
```

**Response — `201 Created`**

```json
{
  "id": 0,
  "is_read": true,
  "date_read": "2026-07-24T06:42:18.725Z",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/collection/stats/`

Returns statistics about the user's collection.

**Response — `200 OK`**

```json
{
  "total_items": 500,
  "total_quantity": 520,
  "total_value": "4500.00",
  "read_count": 450,
  "unread_count": 50,
  "by_format": [
    {
      "book_format": "PRINT",
      "count": 400
    },
    {
      "book_format": "DIGITAL",
      "count": 100
    },
    {
      "book_format": "BOTH",
      "count": 20
    }
  ]
}
```

---


## Creators

### `GET /api/creator/`

Returns a list of all the creators.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `cv_id` | integer | Comic Vine ID |
| `gcd_id` | integer | Grand Comics Database ID |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/creator/{id}/`

Returns the information of an individual creator.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this creator. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "birth": "2026-07-24",
  "death": "2026-07-24",
  "desc": "string",
  "image": "https://example.com/image.jpg",
  "alias": [
    "string"
  ],
  "cv_id": 0,
  "gcd_id": 0,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---


## Imprints

### `GET /api/imprint/`

Returns a list of all imprints.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `cv_id` | integer | Comic Vine ID |
| `gcd_id` | integer | Grand Comics Database ID |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/imprint/{id}/`

Returns the information of an individual imprint.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this imprint. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "founded": 0,
  "desc": "string",
  "image": "https://example.com/image.jpg",
  "cv_id": 0,
  "gcd_id": 0,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---


## Issues

### `GET /api/issue/`

Returns a list of all the issues.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `alt_number` | string | Alternate Number |
| `character_id` | integer | Character Metron ID |
| `cover_hash` | string | Cover Hash |
| `cover_month` | number | Cover Month |
| `cover_year` | number | Cover Year |
| `creator_id` | integer | Creator Metron ID |
| `cv_id` | integer | Comic Vine ID |
| `foc_date` | string (date) | Final order cutoff date |
| `gcd_id` | integer | Grand Comics Database ID |
| `imprint_id` | integer | Imprint Metron ID |
| `imprint_name` | string | Imprint Name |
| `missing_cv_id` | boolean | Only issues missing a Comic Vine ID |
| `missing_gcd_id` | boolean | Only issues missing a GCD ID |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `number` | string | Issue Number |
| `page` | integer | A page number within the paginated result set. |
| `publisher_id` | integer | Publisher Metron ID |
| `publisher_name` | string | Publisher Name |
| `rating` | string | Rating |
| `series_id` | integer | Series Metron ID |
| `series_name` | string | Series Name |
| `series_volume` | integer | Series Volume Number |
| `series_year_began` | integer | Series Beginning Year |
| `sku` | string | Distributor SKU |
| `store_date` | string (date) | In-store date |
| `team_id` | integer | Team Metron ID |
| `universe_id` | integer | Universe Metron ID |
| `upc` | string | UPC Code |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/issue/{id}/`

Returns the information of an individual issue.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this issue. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "number": "string",
  "alt_number": "string",
  "title": "string",
  "name": [
    "string"
  ],
  "cover_date": "2026-07-24",
  "store_date": "2026-07-24",
  "foc_date": "2026-07-24",
  "sku": "string",
  "isbn": "string",
  "upc": "string",
  "page": 0,
  "desc": "string",
  "image": "https://example.com/image.jpg",
  "cover_hash": "string",
  "cv_id": 0,
  "gcd_id": 0,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---


## Publishers

### `GET /api/publisher/`

Returns a list of all publishers.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `cv_id` | integer | Comic Vine ID |
| `gcd_id` | integer | Grand Comics Database ID |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/publisher/{id}/`

Returns the information of an individual publisher.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this publisher. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "alt_names": [
    "string"
  ],
  "founded": 0,
  "desc": "string",
  "image": "https://example.com/image.jpg",
  "cv_id": 0,
  "gcd_id": 0,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/publisher/{id}/series_list/`

Returns a list of series for a publisher.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this publisher. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---


## Pull List

### `GET /api/pull_list/`

Returns the authenticated user's pull lists.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/pull_list/{id}/`

Returns details of a specific pull list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this Pull List. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/pull_list/issues/`

Returns issues for series on the authenticated user's pull list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `page` | integer | A page number within the paginated result set. |
| `store_date_after` | string (date) | Return issues with a store date on or after this date (YYYY-MM-DD). |
| `store_date_before` | string (date) | Return issues with a store date on or before this date (YYYY-MM-DD). |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/pull_list/series/`

Returns the authenticated user's pull list series.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `POST /api/pull_list/series/add/`

Add a series to the authenticated user's pull list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `series_id` | integer | Series ID to add |

**Response — `200 OK`**

```json
{
  "id": 0,
  "added_on": "2026-07-24T06:42:18.725Z"
}
```

---

### `DELETE /api/pull_list/series/{series_pk}/remove/`

Remove a series from the authenticated user's pull list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `series_pk` | integer (path) | Series ID to remove |

**Response — `204 No Content`**

---


## Reading Lists

### `GET /api/reading_list/`

Returns a list of reading lists based on user permissions.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `attribution_source` | string | Source: CBRO, CMRO, CBH, CBT, MG, HTLC, LOCG, OTHER |
| `average_rating__gte` | number | Minimum Rating |
| `is_private` | boolean | Whether the list is private |
| `list_type` | string | Type: CREATOR, EVENT, STORY, CHARACTERS, TEAMS, MASTER |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |
| `publisher` | string | Publisher |
| `user` | integer | user |
| `username` | string | username |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/reading_list/{id}/`

Returns the information of an individual reading list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this reading list. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "slug": "string",
  "desc": "string",
  "is_private": true,
  "attribution_url": "https://example.com/image.jpg",
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/reading_list/{id}/items/`

Returns a paginated list of items for this reading list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this reading list. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---


## Creator Roles

### `GET /api/role/`

Returns a list of all the creator roles.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---


## OpenAPI Schema

### `GET /api/schema/`

OpenAPI 3 schema for this API.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `format` | string | Output format. One of json, yaml |
| `lang` | string | Language code (e.g. en, fr, ja) |

**Response — `200 OK`**

Returns the OpenAPI 3 schema in the requested format (JSON or YAML).

---


## Series

### `GET /api/series/`

Returns a list of all the comic series.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `character_id` | integer | Character Metron ID |
| `creator_id` | integer | Creator Metron ID |
| `cv_id` | integer | Comic Vine ID |
| `gcd_id` | integer | Grand Comics Database ID |
| `imprint_id` | integer | Imprint Metron ID |
| `imprint_name` | string | Imprint Name |
| `missing_cv_id` | boolean | Only series missing a Comic Vine ID |
| `missing_gcd_id` | boolean | Only series missing a GCD ID |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |
| `publisher_id` | integer | Publisher Metron ID |
| `publisher_name` | string | Publisher Name |
| `series_type` | string | Series Type |
| `series_type_id` | integer | Series Type ID |
| `status` | integer | Status |
| `team_id` | integer | Team Metron ID |
| `universe_id` | integer | Universe Metron ID |
| `volume` | integer | Volume Number |
| `year_began` | integer | Beginning Year |
| `year_end` | integer | Ending Year |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/series/{id}/`

Returns the information of an individual comic series.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this series. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "sort_name": "string",
  "alt_names": [
    "string"
  ],
  "volume": 0,
  "year_began": 0,
  "year_end": 0,
  "desc": "string",
  "cv_id": 0,
  "gcd_id": 0,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/series/{id}/issue_list/`

Returns a list of a series' issues.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this series. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---


## Series Types

### `GET /api/series_type/`

Returns a list of the series types available.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---


## Teams

### `GET /api/team/`

Returns a list of all the teams.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `cv_id` | integer | Comic Vine ID |
| `gcd_id` | integer | Grand Comics Database ID |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/team/{id}/`

Returns the information of an individual team.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this team. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "desc": "string",
  "image": "https://example.com/image.jpg",
  "cv_id": 0,
  "gcd_id": 0,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/team/{id}/issue_list/`

Returns a list of issues featuring the team.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this team. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---


## Universes

### `GET /api/universe/`

Returns a list of all the universes.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `designation` | string | Universe designation (e.g. Earth-616) |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/universe/{id}/`

Returns the information of an individual universe.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this universe. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "designation": "string",
  "desc": "string",
  "gcd_id": 0,
  "image": "https://example.com/image.jpg",
  "resource_url": "string",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---


## Wish List

### `GET /api/wish_list/`

Returns paginated wish lists for the authenticated user.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `GET /api/wish_list/{id}/`

Returns details of a specific wish list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` | integer (path) | A unique integer value identifying this Wish List. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `GET /api/wish_list/items/`

Returns paginated wish list items for the authenticated user.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 0,
  "next": "https://example.com/image.jpg",
  "previous": "https://example.com/image.jpg",
  "results": []
}
```

---

### `POST /api/wish_list/items/add/`

Add an issue to the authenticated user's wish list.

**Request Body**

```json
{
  "issue_id": 123,
  "priority": 3,
  "desired_grade": null,
  "max_price": null,
  "max_price_currency": "USD",
  "notes": ""
}
```

**Response — `201 Created`**

```json
{
  "id": 0,
  "max_price": "3.99",
  "notes": "string",
  "added_on": "2026-07-24T06:42:18.725Z",
  "modified": "2026-07-24T06:42:18.725Z"
}
```

---

### `POST /api/wish_list/items/{item_pk}/acquire/`

Mark a wish list item as acquired and create a collection item.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `item_pk` | integer (path) | Wish list item ID |

**Request Body**

```json
{
  "purchase_date": "2026-09-03",
  "purchase_price": "29.99",
  "purchase_price_currency": "USD",
  "purchase_store": "Local Comic Shop",
  "notes": ""
}
```

**Response — `200 OK`**

```json
{}
```

---

### `DELETE /api/wish_list/items/{item_pk}/remove/`

Remove an item from the authenticated user's wish list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `item_pk` | integer (path) | Wish list item ID |

**Response — `204 No Content`**

---
