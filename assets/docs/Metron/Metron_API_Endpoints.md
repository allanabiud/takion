# Metron API Endpoints

Reference for the Metron API endpoints. All endpoints live under `https://metron.cloud`.

- All requests require HTTP Basic authentication (username + password).
- Responses are paginated using the standard DRF format (`count`, `next`, `previous`, `results`).
- Read endpoints (`GET`) are open to any authenticated user. Write operations (create/update on imprints, publishers, series) require the Editor or Admin role.
- `next` and `previous` pagination URLs are ready to use — pass them straight to your HTTP client.

## Endpoint Overview

| Endpoint | Description |
|---|---|
| `GET /api/arc/` | List story arcs |
| `GET /api/arc/{id}/` | Retrieve a story arc |
| `GET /api/arc/{id}/issue_list/` | List issues in a story arc |
| `GET /api/character/` | List characters |
| `GET /api/character/{id}/` | Retrieve a character |
| `GET /api/character/{id}/issue_list/` | List a character's appearances |
| `GET /api/creator/` | List creators |
| `GET /api/creator/{id}/` | Retrieve a creator |
| `GET /api/imprint/` | List imprints |
| `GET /api/imprint/{id}/` | Retrieve an imprint |
| `GET /api/issue/` | List issues |
| `GET /api/issue/{id}/` | Retrieve an issue |
| `GET /api/publisher/` | List publishers |
| `GET /api/publisher/{id}/` | Retrieve a publisher |
| `GET /api/publisher/{id}/series_list/` | List a publisher's series |
| `GET /api/reading_list/` | List reading lists |
| `GET /api/reading_list/{id}/` | Retrieve a reading list |
| `GET /api/reading_list/{id}/items/` | List a reading list's items |
| `GET /api/role/` | List creator roles |
| `GET /api/schema/` | OpenAPI schema for the API |
| `GET /api/series/` | List series |
| `GET /api/series/{id}/` | Retrieve a series |
| `GET /api/series/{id}/issue_list/` | List a series' issues |
| `GET /api/series_type/` | List series types |
| `GET /api/team/` | List teams |
| `GET /api/team/{id}/` | Retrieve a team |
| `GET /api/team/{id}/issue_list/` | List issues featuring a team |
| `GET /api/universe/` | List universes |
| `GET /api/universe/{id}/` | Retrieve a universe |

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:42:18.725Z"
    }
  ]
}
```

### `GET /api/arc/{id}/`

Returns the information of an individual story arc.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this arc. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "desc": "string",
  "image": "string",
  "cv_id": 2147483647,
  "gcd_id": 2147483647,
  "resource_url": "string",
  "modified": "2026-07-24T06:42:33.476Z"
}
```

### `GET /api/arc/{id}/issue_list/`

Returns the list of issues in a story arc.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this arc. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "series": {
        "id": 0,
        "name": "string",
        "volume": 32767,
        "year_began": 32767
      },
      "number": "string",
      "issue": "string",
      "cover_date": "2026-07-24",
      "store_date": "2026-07-24",
      "image": "string",
      "cover_hash": "string",
      "modified": "2026-07-24T06:42:48.471Z"
    }
  ]
}
```

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:42:58.132Z"
    }
  ]
}
```

### `GET /api/character/{id}/`

Returns the information of an individual character.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this character. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "alias": [
    "string"
  ],
  "desc": "string",
  "image": "string",
  "creators": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:43:08.035Z"
    }
  ],
  "teams": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:43:08.035Z"
    }
  ],
  "universes": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:43:08.035Z"
    }
  ],
  "cv_id": 2147483647,
  "gcd_id": 2147483647,
  "resource_url": "string",
  "modified": "2026-07-24T06:43:08.035Z"
}
```

### `GET /api/character/{id}/issue_list/`

Returns a list of a character's appearances.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this character. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "series": {
        "id": 0,
        "name": "string",
        "volume": 32767,
        "year_began": 32767
      },
      "number": "string",
      "issue": "string",
      "cover_date": "2026-07-24",
      "store_date": "2026-07-24",
      "image": "string",
      "cover_hash": "string",
      "modified": "2026-07-24T06:43:22.769Z"
    }
  ]
}
```

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:43:46.396Z"
    }
  ]
}
```

### `GET /api/creator/{id}/`

Returns the information of an individual creator.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this creator. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "birth": "2026-07-24",
  "death": "2026-07-24",
  "desc": "string",
  "image": "string",
  "alias": [
    "string"
  ],
  "cv_id": 2147483647,
  "gcd_id": 2147483647,
  "resource_url": "string",
  "modified": "2026-07-24T06:43:57.315Z"
}
```

## Imprints

### `GET /api/imprint/`

Returns a list of all imprints. Supports list, retrieve, create, and update operations — write operations require the Editor or Admin role.

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:44:09.126Z"
    }
  ]
}
```

### `GET /api/imprint/{id}/`

Returns the information of an individual imprint.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this imprint. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "founded": 32767,
  "desc": "string",
  "image": "string",
  "cv_id": 2147483647,
  "gcd_id": 2147483647,
  "publisher": {
    "id": 0,
    "name": "string"
  },
  "resource_url": "string",
  "modified": "2026-07-24T06:44:23.437Z"
}
```

## Issues

### `GET /api/issue/`

Returns a list of all the issues.

> **Note:** `cover_hash` is a perceptual hash created with [ImageHash](https://github.com/JohannesBuchner/imagehash).

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
| `foc_date_range_after` | string (date) | Final order cutoff date — on or after |
| `foc_date_range_before` | string (date) | Final order cutoff date — on or before |
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
| `role_id` | array\<integer\> | Multiple values may be separated by commas. |
| `series_id` | integer | Series Metron ID |
| `series_name` | string | Series Name |
| `series_volume` | integer | Series Volume Number |
| `series_year_began` | integer | Series Beginning Year |
| `sku` | string | Distributor SKU |
| `store_date` | string (date) | In-store date |
| `store_date_range_after` | string (date) | In-store date — on or after |
| `store_date_range_before` | string (date) | In-store date — on or before |
| `team_id` | integer | Team Metron ID |
| `universe_id` | integer | Universe Metron ID |
| `upc` | string | UPC Code |
| `upc_starts_with` | string | UPC Code starts with (e.g. the 12-digit UPC-A read by a mobile scanner that strips the 5-digit EAN supplemental) |

**Response — `200 OK`**

```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "series": {
        "id": 0,
        "name": "string",
        "volume": 32767,
        "year_began": 32767
      },
      "number": "string",
      "issue": "string",
      "cover_date": "2026-07-24",
      "store_date": "2026-07-24",
      "image": "string",
      "cover_hash": "string",
      "modified": "2026-07-24T06:44:33.662Z"
    }
  ]
}
```

### `GET /api/issue/{id}/`

Returns the information of an individual issue.

> **Note:** `cover_hash` is a perceptual hash created with [ImageHash](https://github.com/JohannesBuchner/imagehash).

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this issue. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "publisher": {
    "id": 0,
    "name": "string"
  },
  "imprint": {
    "id": 0,
    "name": "string"
  },
  "series": {
    "id": 0,
    "name": "string",
    "sort_name": "string",
    "volume": 32767,
    "year_began": 32767,
    "series_type": {
      "id": 0,
      "name": "string"
    },
    "genres": [
      {
        "id": 0,
        "name": "string"
      }
    ]
  },
  "number": "string",
  "alt_number": "string",
  "title": "string",
  "name": [
    "string"
  ],
  "cover_date": "2026-07-24",
  "store_date": "2026-07-24",
  "foc_date": "2026-07-24",
  "price": "3.99",
  "price_currency": "string",
  "rating": {
    "id": 0,
    "name": "string"
  },
  "sku": "string",
  "isbn": "string",
  "upc": "string",
  "page": 32767,
  "desc": "string",
  "image": "string",
  "cover_hash": "string",
  "average_rating": 9,
  "rating_count": 0,
  "arcs": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:44:47.523Z"
    }
  ],
  "credits": [
    {
      "id": 0,
      "creator": "string",
      "role": [
        {
          "id": 0,
          "name": "string"
        }
      ]
    }
  ],
  "characters": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:44:47.523Z"
    }
  ],
  "teams": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:44:47.523Z"
    }
  ],
  "universes": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:44:47.523Z"
    }
  ],
  "reprints": [
    {
      "id": 0,
      "issue": "string"
    }
  ],
  "variants": [
    {
      "name": "string",
      "price": "3.99",
      "sku": "string",
      "upc": "string",
      "image": "string"
    }
  ],
  "cv_id": 2147483647,
  "gcd_id": 2147483647,
  "resource_url": "string",
  "modified": "2026-07-24T06:44:47.523Z"
}
```

## Publishers

### `GET /api/publisher/`

Returns a list of all publishers. Supports list, retrieve, create, and update operations — write operations require the Editor or Admin role.

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:44:59.252Z"
    }
  ]
}
```

### `GET /api/publisher/{id}/`

Returns the information of an individual publisher.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this publisher. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "founded": 32767,
  "country": "AF",
  "desc": "string",
  "image": "string",
  "cv_id": 2147483647,
  "gcd_id": 2147483647,
  "resource_url": "string",
  "modified": "2026-07-24T06:45:08.566Z"
}
```

### `GET /api/publisher/{id}/series_list/`

Returns a list of series for a publisher.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this publisher. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "series": "string",
      "year_began": 32767,
      "year_end": 32767,
      "volume": 32767,
      "issue_count": 0,
      "modified": "2026-07-24T06:45:18.901Z"
    }
  ]
}
```

## Reading Lists

### `GET /api/reading_list/`

Returns a list of reading lists based on user permissions. Requires authentication.

- **Authenticated users:** Public lists + own lists
- **Admin users:** Public lists + own lists + Metron's lists

**Parameters**

| Name | Type | Description |
|---|---|---|
| `attribution_source` | string | Source where this reading list information was obtained. One of `CBRO`, `CMRO`, `CBH`, `CBT`, `MG`, `HTLC`, `LOCG`, `OTHER` |
| `average_rating__gte` | number | Minimum Rating |
| `is_private` | boolean | Whether the list is private |
| `list_type` | string | The type of reading list. One of `CREATOR`, `EVENT`, `STORY`, `CHARACTERS`, `TEAMS`, `MASTER` |
| `modified_gt` | string (date-time) | Greater than Modified DateTime |
| `name` | string | name |
| `page` | integer | A page number within the paginated result set. |
| `publisher` | string | Publisher |
| `user` | integer | user |
| `username` | string | username |

**Response — `200 OK`**

```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "slug": "rEQ6c1BS_2oQfnSq6MejkuTRwqvvmS2x_Olxw1sxWOE0z639uxwAUBp7V4q7q-WhXEiV0RCN4pn0gwqakf_mn",
      "user": {
        "id": 0,
        "username": "8yXPsbfwwF+U8z2pgGq-fZL+eEuE-.90o1piX9DoObcbs_-cbp8Hly"
      },
      "list_type": "string",
      "is_private": true,
      "attribution_source": "CBRO",
      "average_rating": 0,
      "rating_count": 0,
      "modified": "2026-07-24T06:45:29.818Z"
    }
  ]
}
```

### `GET /api/reading_list/{id}/`

Returns the information of an individual reading list. Requires authentication.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this reading list. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "user": {
    "id": 0,
    "username": "RLMejgaC-347p-sDIBJDvXW5elIG1s32tejZhSTC6jFcbxezQ2mo_FT+mY63pe"
  },
  "name": "string",
  "slug": "WSk6hGMUUHHYtdxjVAcP7qDVDGmx",
  "desc": "string",
  "image": "string",
  "list_type": "string",
  "is_private": true,
  "attribution_source": "string",
  "attribution_url": "string",
  "previous": {
    "id": 0,
    "name": "string"
  },
  "next": {
    "id": 0,
    "name": "string"
  },
  "average_rating": 0,
  "rating_count": 0,
  "items_url": "string",
  "resource_url": "string",
  "modified": "2026-07-24T06:45:43.194Z"
}
```

### `GET /api/reading_list/{id}/items/`

Returns a paginated list of items for this reading list.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this reading list. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "issue": {
        "id": 0,
        "series": {
          "id": 0,
          "name": "string",
          "volume": 32767,
          "year_began": 32767
        },
        "number": "string",
        "cover_date": "2026-07-24",
        "store_date": "2026-07-24",
        "cv_id": 2147483647,
        "gcd_id": 2147483647,
        "modified": "2026-07-24T06:45:54.359Z"
      },
      "order": 2147483647,
      "issue_type": "string"
    }
  ]
}
```

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string"
    }
  ]
}
```

## OpenAPI Schema

### `GET /api/schema/`

OpenAPI 3 schema for this API. The format can be selected via content negotiation:

- **YAML:** `application/vnd.oai.openapi`
- **JSON:** `application/vnd.oai.openapi+json`

**Parameters**

| Name | Type | Description |
|---|---|---|
| `format` | string | Output format. One of `json`, `yaml` |
| `lang` | string | Language code (e.g. `en`, `fr`, `ja`) |

**Response — `200 OK`**

```json
{
  "additionalProp1": "string",
  "additionalProp2": "string",
  "additionalProp3": "string"
}
```

## Series

### `GET /api/series/`

Returns a list of all the comic series. Supports list, retrieve, create, and update operations — write operations require the Editor or Admin role.

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
| `role_id` | array\<integer\> | Multiple values may be separated by commas. |
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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "series": "string",
      "year_began": 32767,
      "year_end": 32767,
      "volume": 32767,
      "issue_count": 0,
      "modified": "2026-07-24T06:46:38.642Z"
    }
  ]
}
```

### `GET /api/series/{id}/`

Returns the information of an individual comic series.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this series. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "sort_name": "string",
  "volume": 32767,
  "series_type": {
    "id": 0,
    "name": "string"
  },
  "status": "string",
  "publisher": {
    "id": 0,
    "name": "string"
  },
  "imprint": {
    "id": 0,
    "name": "string"
  },
  "year_began": 32767,
  "year_end": 32767,
  "desc": "string",
  "issue_count": 0,
  "genres": [
    {
      "id": 0,
      "name": "string"
    }
  ],
  "associated": [
    {
      "id": 0,
      "series": "string"
    }
  ],
  "cv_id": 2147483647,
  "gcd_id": 2147483647,
  "resource_url": "string",
  "modified": "2026-07-24T06:46:49.165Z"
}
```

### `GET /api/series/{id}/issue_list/`

Returns a list of a series' issues.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this series. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "series": {
        "id": 0,
        "name": "string",
        "volume": 32767,
        "year_began": 32767
      },
      "number": "string",
      "issue": "string",
      "cover_date": "2026-07-24",
      "store_date": "2026-07-24",
      "image": "string",
      "cover_hash": "string",
      "modified": "2026-07-24T06:46:49.442Z"
    }
  ]
}
```

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string"
    }
  ]
}
```

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:47:28.991Z"
    }
  ]
}
```

### `GET /api/team/{id}/`

Returns the information of an individual team.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this team. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "name": "string",
  "desc": "string",
  "image": "string",
  "creators": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:47:38.335Z"
    }
  ],
  "universes": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:47:38.335Z"
    }
  ],
  "cv_id": 2147483647,
  "gcd_id": 2147483647,
  "resource_url": "string",
  "modified": "2026-07-24T06:47:38.335Z"
}
```

### `GET /api/team/{id}/issue_list/`

Returns a list of issues featuring the team.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this team. |
| `page` | integer | A page number within the paginated result set. |

**Response — `200 OK`**

```json
{
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "series": {
        "id": 0,
        "name": "string",
        "volume": 32767,
        "year_began": 32767
      },
      "number": "string",
      "issue": "string",
      "cover_date": "2026-07-24",
      "store_date": "2026-07-24",
      "image": "string",
      "cover_hash": "string",
      "modified": "2026-07-24T06:47:50.686Z"
    }
  ]
}
```

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
  "count": 123,
  "next": "http://api.example.org/accounts/?page=4",
  "previous": "http://api.example.org/accounts/?page=2",
  "results": [
    {
      "id": 0,
      "name": "string",
      "modified": "2026-07-24T06:48:01.996Z"
    }
  ]
}
```

### `GET /api/universe/{id}/`

Returns the information of an individual universe.

**Parameters**

| Name | Type | Description |
|---|---|---|
| `id` * | integer (path) | A unique integer value identifying this universe. |

**Response — `200 OK`**

```json
{
  "id": 0,
  "publisher": {
    "id": 0,
    "name": "string"
  },
  "name": "string",
  "designation": "string",
  "desc": "string",
  "gcd_id": 2147483647,
  "image": "string",
  "resource_url": "string",
  "modified": "2026-07-24T06:48:12.521Z"
}
```
