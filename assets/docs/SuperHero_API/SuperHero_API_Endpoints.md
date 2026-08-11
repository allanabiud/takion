# SuperHero API Endpoints

BASE URL: `https://superheroapi.com/api/access-token`

An access token is required and must be generated via GitHub login at https://superheroapi.com. It is passed as the first path segment: `https://superheroapi.com/api/{access-token}/...`

## Reference

| Endpoint              | Method | Purpose                                                                 |
|-----------------------|--------|-------------------------------------------------------------------------|
| `/{id}`               | GET    | Search by character id. Returns all information of the character.       |
| `/{id}/powerstats`    | GET    | Returns JSON of all powerstats of the given character.                  |
| `/{id}/biography`     | GET    | Returns JSON of the character's biography.                              |
| `/{id}/appearance`    | GET    | Returns JSON of the character's appearance.                             |
| `/{id}/work`          | GET    | Returns JSON of the character's work (occupation and operation base).   |
| `/{id}/connections`   | GET    | Returns JSON of the character's connections.                            |
| `/{id}/image`         | GET    | Returns the image URL of the character, if it exists.                   |
| `/search/{name}`      | GET    | Search character by name. Returns the character ids.                    |

Note: `/{id}` responses include a `response` field with value `"success"` (or `"error"` with an `error` message when the id is unknown).

---

## GET /{id}

Search by character id. Returns all information of the character.

### Path Parameters

| Name | Type | Description |
|------|------|-------------|
| id * | string | The character id. |

### Example Value

```json
{
  "response": "success",
  "id": "70",
  "name": "Batman",
  "powerstats": {
    "intelligence": "100",
    "strength": "26",
    "speed": "27",
    "durability": "50",
    "power": "47",
    "combat": "100"
  },
  "biography": {
    "full-name": "Bruce Wayne",
    "alter-egos": "No alter egos found.",
    "aliases": [
      "Insider",
      "Matches Malone"
    ],
    "place-of-birth": "Crest Hill, Bristol Township; Gotham County",
    "first-appearance": "Detective Comics #27",
    "publisher": "DC Comics",
    "alignment": "good"
  },
  "appearance": {
    "gender": "Male",
    "race": "Human",
    "height": [
      "6'2",
      "188 cm"
    ],
    "weight": [
      "210 lb",
      "95 kg"
    ],
    "eye-color": "blue",
    "hair-color": "black"
  },
  "work": {
    "occupation": "Businessman",
    "base": "Batcave, Stately Wayne Manor, Gotham City; Hall of Justice, Justice League Watchtower"
  },
  "connections": {
    "group-affiliation": "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
    "relatives": "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward)\nMartha Wayne (mother, deceased), Thomas Wayne (father, deceased), Alfred Pennyworth (former guardian), Roderick Kane (grandfather, deceased), Elizabeth Kane (grandmother, deceased), Nathan Kane (uncle, deceased), Simon Hurt (ancestor), Wayne Family"
  },
  "image": {
    "url": "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg"
  }
}
```

---

## GET /{id}/powerstats

Returns JSON of all powerstats of the given character.

The powerstats are: Intelligence, Strength, Speed, Durability, Power, Combat.

### Path Parameters

| Name | Type | Description |
|------|------|-------------|
| id * | string | The character id. |

### Example Value

```json
{
  "response": "success",
  "id": "70",
  "name": "Batman",
  "intelligence": "100",
  "strength": "26",
  "speed": "27",
  "durability": "50",
  "power": "47",
  "combat": "100"
}
```

---

## GET /{id}/biography

Returns JSON of the biographical stats of the character.

The fields are: Full Name, Alter Egos, Aliases, Place of Birth, First Appearance, Publisher, Alignment.

### Path Parameters

| Name | Type | Description |
|------|------|-------------|
| id * | string | The character id. |

### Example Value

```json
{
  "response": "success",
  "id": "70",
  "name": "Batman",
  "full-name": "Bruce Wayne",
  "alter-egos": "No alter egos found.",
  "aliases": [
    "Insider",
    "Matches Malone"
  ],
  "place-of-birth": "Crest Hill, Bristol Township; Gotham County",
  "first-appearance": "Detective Comics #27",
  "publisher": "DC Comics",
  "alignment": "good"
}
```

---

## GET /{id}/appearance

Returns JSON of the appearance of the character.

The various statistics are: Gender, Race, Height, Weight, Eye Color, Hair Color.

### Path Parameters

| Name | Type | Description |
|------|------|-------------|
| id * | string | The character id. |

### Example Value

```json
{
  "response": "success",
  "id": "70",
  "name": "Batman",
  "gender": "Male",
  "race": "Human",
  "height": [
    "6'2",
    "188 cm"
  ],
  "weight": [
    "210 lb",
    "95 kg"
  ],
  "eye-color": "blue",
  "hair-color": "black"
}
```

---

## GET /{id}/work

Returns JSON of the work/occupation of the character.

The fields are: Occupation, Base of operation.

### Path Parameters

| Name | Type | Description |
|------|------|-------------|
| id * | string | The character id. |

### Example Value

```json
{
  "response": "success",
  "id": "70",
  "name": "Batman",
  "occupation": "Businessman",
  "base": "Batcave, Stately Wayne Manor, Gotham City; Hall of Justice, Justice League Watchtower"
}
```

---

## GET /{id}/connections

Returns JSON of the connections of the character.

The fields are: Group Affiliation, Relatives.

### Path Parameters

| Name | Type | Description |
|------|------|-------------|
| id * | string | The character id. |

### Example Value

```json
{
  "response": "success",
  "id": "70",
  "name": "Batman",
  "group-affiliation": "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
  "relatives": "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward)\nMartha Wayne (mother, deceased), Thomas Wayne (father, deceased), Alfred Pennyworth (former guardian), Roderick Kane (grandfather, deceased), Elizabeth Kane (grandmother, deceased), Nathan Kane (uncle, deceased), Simon Hurt (ancestor), Wayne Family"
}
```

---

## GET /{id}/image

Returns the image for the character, if it exists.

### Path Parameters

| Name | Type | Description |
|------|------|-------------|
| id * | string | The character id. |

### Example Value

```json
{
  "response": "success",
  "id": "70",
  "name": "Batman",
  "url": "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg"
}
```

---

## GET /search/{name}

Helps you find the character-id of a character by searching its name.

### Path Parameters

| Name | Type | Description |
|------|------|-------------|
| name * | string | The character name to search. |

### Example Value

```json
{
  "response": "success",
  "results-for": "batman",
  "results": [
    {
      "id": "69",
      "name": "Batman",
      "powerstats": {
        "intelligence": "81",
        "strength": "40",
        "speed": "29",
        "durability": "55",
        "power": "63",
        "combat": "90"
      },
      "biography": {
        "full-name": "Terry McGinnis",
        "alter-egos": "No alter egos found.",
        "aliases": [
          "Batman II",
          "The Tomorrow Knight",
          "The second Dark Knight",
          "The Dark Knight of Tomorrow",
          "Batman Beyond"
        ],
        "place-of-birth": "Gotham City, 25th Century",
        "first-appearance": "Batman Beyond #1",
        "publisher": "DC Comics",
        "alignment": "good"
      },
      "appearance": {
        "gender": "Male",
        "race": "Human",
        "height": [
          "5'10",
          "178 cm"
        ],
        "weight": [
          "170 lb",
          "77 kg"
        ],
        "eye-color": "Blue",
        "hair-color": "Black"
      },
      "work": {
        "occupation": "-",
        "base": "21st Century Gotham City"
      },
      "connections": {
        "group-affiliation": "Batman Family, Justice League Unlimited",
        "relatives": "Bruce Wayne (biological father), Warren McGinnis (father, deceased), Mary McGinnis (mother), Matt McGinnis (brother)"
      },
      "image": {
        "url": "https://www.superherodb.com/pictures2/portraits/10/100/10441.jpg"
      }
    },
    {
      "id": "70",
      "name": "Batman",
      "powerstats": {
        "intelligence": "100",
        "strength": "26",
        "speed": "27",
        "durability": "50",
        "power": "47",
        "combat": "100"
      },
      "biography": {
        "full-name": "Bruce Wayne",
        "alter-egos": "No alter egos found.",
        "aliases": [
          "Insider",
          "Matches Malone"
        ],
        "place-of-birth": "Crest Hill, Bristol Township; Gotham County",
        "first-appearance": "Detective Comics #27",
        "publisher": "DC Comics",
        "alignment": "good"
      },
      "appearance": {
        "gender": "Male",
        "race": "Human",
        "height": [
          "6'2",
          "188 cm"
        ],
        "weight": [
          "210 lb",
          "95 kg"
        ],
        "eye-color": "blue",
        "hair-color": "black"
      },
      "work": {
        "occupation": "Businessman",
        "base": "Batcave, Stately Wayne Manor, Gotham City; Hall of Justice, Justice League Watchtower"
      },
      "connections": {
        "group-affiliation": "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
        "relatives": "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward)\nMartha Wayne (mother, deceased), Thomas Wayne (father, deceased), Alfred Pennyworth (former guardian), Roderick Kane (grandfather, deceased), Elizabeth Kane (grandmother, deceased), Nathan Kane (uncle, deceased), Simon Hurt (ancestor), Wayne Family"
      },
      "image": {
        "url": "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg"
      }
    }
  ]
}
```
