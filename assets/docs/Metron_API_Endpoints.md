api

GET
/api/arc/

list: Returns a list of all the story arcs.

retrieve: Returns the information of an individual story arc.

Parameters
Try it out
Name Description
cv_id
integer
(query)
Comic Vine ID

cv_id
gcd_id
integer
(query)
Grand Comics Database ID

gcd_id
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/arc/{id}/

list: Returns a list of all the story arcs.

retrieve: Returns the information of an individual story arc.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this arc.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/arc/{id}/issue_list/

list: Returns a list of all the story arcs.

retrieve: Returns the information of an individual story arc.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this arc.

id
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/character/

list: Return a list of all the characters.

retrieve: Returns the information of an individual character.

Parameters
Try it out
Name Description
cv_id
integer
(query)
Comic Vine ID

cv_id
gcd_id
integer
(query)
Grand Comics Database ID

gcd_id
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/character/{id}/

list: Return a list of all the characters.

retrieve: Returns the information of an individual character.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this character.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/character/{id}/issue_list/

list: Return a list of all the characters.

retrieve: Returns the information of an individual character.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this character.

id
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/creator/

list: Return a list of all the creators.

retrieve: Returns the information of an individual creator.

Parameters
Try it out
Name Description
cv_id
integer
(query)
Comic Vine ID

cv_id
gcd_id
integer
(query)
Grand Comics Database ID

gcd_id
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/creator/{id}/

list: Return a list of all the creators.

retrieve: Returns the information of an individual creator.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this creator.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/imprint/

list: Returns a list of all imprints.

retrieve: Returns the information of an individual imprint.

create: Add a new imprint.

update: Update an imprint's information.

Parameters
Try it out
Name Description
cv_id
integer
(query)
Comic Vine ID

cv_id
gcd_id
integer
(query)
Grand Comics Database ID

gcd_id
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/imprint/{id}/

list: Returns a list of all imprints.

retrieve: Returns the information of an individual imprint.

create: Add a new imprint.

update: Update an imprint's information.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this imprint.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/issue/

list: Return a list of all the issues.

retrieve: Returns the information of an individual issue.

Note: cover_hash is a Perceptual hashing created with ImageHash. https://github.com/JohannesBuchner/imagehash

Parameters
Try it out
Name Description
alt_number
string
(query)
Alternate Number

alt_number
character_id
integer
(query)
Character Metron ID

character_id
cover_hash
string
(query)
Cover Hash

cover_hash
cover_month
number
(query)
Cover Month

cover_month
cover_year
number
(query)
Cover Year

cover_year
creator_id
integer
(query)
Creator Metron ID

creator_id
cv_id
integer
(query)
Comic Vine ID

cv_id
foc_date
string($date)
(query)
foc_date
foc_date_range_after
string($date)
(query)
foc_date_range_after
foc_date_range_before
string($date)
(query)
foc_date_range_before
gcd_id
integer
(query)
Grand Comics Database ID

gcd_id
imprint_id
integer
(query)
Imprint Metron ID

imprint_id
imprint_name
string
(query)
Imprint Name

imprint_name
missing_cv_id
boolean
(query)

--
missing_gcd_id
boolean
(query)

--
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
number
string
(query)
Issue Number

number
page
integer
(query)
A page number within the paginated result set.

page
publisher_id
integer
(query)
Publisher Metron ID

publisher_id
publisher_name
string
(query)
Publisher Name

publisher_name
rating
string
(query)
Rating

rating
role_id
array<integer>
(query)
Multiple values may be separated by commas.

series_id
integer
(query)
Series Metron ID

series_id
series_name
string
(query)
Series Name

series_name
series_volume
integer
(query)
Series Volume Number

series_volume
series_year_began
integer
(query)
Series Beginning Year

series_year_began
sku
string
(query)
Distributor SKU

sku
store_date
string($date)
(query)
store_date
store_date_range_after
string($date)
(query)
store_date_range_after
store_date_range_before
string($date)
(query)
store_date_range_before
team_id
integer
(query)
Team Metron ID

team_id
universe_id
integer
(query)
Universe Metron ID

universe_id
upc
string
(query)
UPC Code

upc
upc_starts_with
string
(query)
UPC Code starts with (e.g. the 12-digit UPC-A read by a mobile scanner that strips the 5-digit EAN supplemental)

upc_starts_with
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/issue/{id}/

list: Return a list of all the issues.

retrieve: Returns the information of an individual issue.

Note: cover_hash is a Perceptual hashing created with ImageHash. https://github.com/JohannesBuchner/imagehash

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this issue.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/publisher/

list: Returns a list of all publishers.

retrieve: Returns the information of an individual publisher.

create: Add a new publisher.

update: Update a publisher's information.

Parameters
Try it out
Name Description
cv_id
integer
(query)
Comic Vine ID

cv_id
gcd_id
integer
(query)
Grand Comics Database ID

gcd_id
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/publisher/{id}/

list: Returns a list of all publishers.

retrieve: Returns the information of an individual publisher.

create: Add a new publisher.

update: Update a publisher's information.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this publisher.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/publisher/{id}/series_list/

Returns a list of series for a publisher.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this publisher.

id
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/reading_list/

list: Returns a list of reading lists based on user permissions. Requires authentication.

Authenticated users: Public lists + own lists
Admin users: Public lists + own lists + Metron's lists
retrieve: Returns the information of an individual reading list. Requires authentication.

Parameters
Try it out
Name Description
attribution_source
string
(query)
Source where this reading list information was obtained

CBRO - Comic Book Reading Orders
CMRO - Complete Marvel Reading Orders
CBH - Comic Book Herald
CBT - Comic Book Treasury
MG - Marvel Guides
HTLC - How To Love Comics
LOCG - League of ComicGeeks
OTHER - Other
Available values : CBH, CBRO, CBT, CMRO, HTLC, LOCG, MG, OTHER

--
average_rating__gte
number
(query)
Minimum Rating

average_rating__gte
is_private
boolean
(query)

--
list_type
string
(query)
The type of reading list

CREATOR - Creator
EVENT - Event
STORY - Story
CHARACTERS - Characters
TEAMS - Teams
MASTER - Master
Available values : CHARACTERS, CREATOR, EVENT, MASTER, STORY, TEAMS

--
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
publisher
string
(query)
Publisher

publisher
user
integer
(query)
user
username
string
(query)
username
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/reading_list/{id}/

list: Returns a list of reading lists based on user permissions. Requires authentication.

Authenticated users: Public lists + own lists
Admin users: Public lists + own lists + Metron's lists
retrieve: Returns the information of an individual reading list. Requires authentication.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this reading list.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/reading_list/{id}/items/

Returns a paginated list of items for this reading list.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this reading list.

id
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/role/

list: Returns a list of all the creator roles.

Parameters
Try it out
Name Description
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/schema/

OpenApi3 schema for this API. Format can be selected via content negotiation.

YAML: application/vnd.oai.openapi
JSON: application/vnd.oai.openapi+json
Parameters
Try it out
Name Description
format
string
(query)
Available values : json, yaml

--
lang
string
(query)
Available values : af, ar, ar-dz, ast, az, be, bg, bn, br, bs, ca, ckb, cs, cy, da, de, dsb, el, en, en-au, en-gb, eo, es, es-ar, es-co, es-mx, es-ni, es-ve, et, eu, fa, fi, fr, fy, ga, gd, gl, he, hi, hr, hsb, ht, hu, hy, ia, id, ig, io, is, it, ja, ka, kab, kk, km, kn, ko, ky, lb, lt, lv, mk, ml, mn, mr, ms, my, nb, ne, nl, nn, os, pa, pl, pt, pt-br, ro, ru, sk, sl, sq, sr, sr-latn, sv, sw, ta, te, tg, th, tk, tr, tt, udm, ug, uk, ur, uz, vi, zh-hans, zh-hant

--
Responses
Code Description Links
200
Media type

application/vnd.oai.openapi
Controls Accept header.
Example Value
Schema
{
"additionalProp1": "string",
"additionalProp2": "string",
"additionalProp3": "string"
}

GET
/api/series/

list: Returns a list of all the comic series.

retrieve: Returns the information of an individual comic series.

create: Add a new Series.

update: Update a Series information.

Parameters
Try it out
Name Description
character_id
integer
(query)
Character Metron ID

character_id
creator_id
integer
(query)
Creator Metron ID

creator_id
cv_id
integer
(query)
Comic Vine ID

cv_id
gcd_id
integer
(query)
Grand Comics Database ID

gcd_id
imprint_id
integer
(query)
Imprint Metron ID

imprint_id
imprint_name
string
(query)
imprint_name
missing_cv_id
boolean
(query)

--
missing_gcd_id
boolean
(query)

--
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
publisher_id
integer
(query)
publisher_id
publisher_name
string
(query)
publisher_name
role_id
array<integer>
(query)
Multiple values may be separated by commas.

series_type
string
(query)
series_type
series_type_id
integer
(query)
series_type_id
status
integer
(query)
status
team_id
integer
(query)
Team Metron ID

team_id
universe_id
integer
(query)
Universe Metron ID

universe_id
volume
integer
(query)
volume
year_began
integer
(query)
year_began
year_end
integer
(query)
year_end
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/series/{id}/

list: Returns a list of all the comic series.

retrieve: Returns the information of an individual comic series.

create: Add a new Series.

update: Update a Series information.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this series.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/series/{id}/issue_list/

list: Returns a list of all the comic series.

retrieve: Returns the information of an individual comic series.

create: Add a new Series.

update: Update a Series information.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this series.

id
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/series_type/

list: Returns a list of the Series Types available.

Parameters
Try it out
Name Description
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/team/

list: Return a list of all the teams.

retrieve: Returns the information of an individual team.

Parameters
Try it out
Name Description
cv_id
integer
(query)
Comic Vine ID

cv_id
gcd_id
integer
(query)
Grand Comics Database ID

gcd_id
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/team/{id}/

list: Return a list of all the teams.

retrieve: Returns the information of an individual team.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this team.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/team/{id}/issue_list/

list: Return a list of all the teams.

retrieve: Returns the information of an individual team.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this team.

id
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/universe/

list: Return a list of all the universes.

retrieve: Returns the information of an individual universe.

Parameters
Try it out
Name Description
designation
string
(query)
designation
modified_gt
string($date-time)
(query)
Greater than Modified DateTime

modified_gt
name
string
(query)
name
page
integer
(query)
A page number within the paginated result set.

page
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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

GET
/api/universe/{id}/

list: Return a list of all the universes.

retrieve: Returns the information of an individual universe.

Parameters
Try it out
Name Description
id *
integer
(path)
A unique integer value identifying this universe.

id
Responses
Code Description Links
200
Media type

application/json
Controls Accept header.
Example Value
Schema
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
