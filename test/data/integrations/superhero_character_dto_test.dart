import "package:flutter_test/flutter_test.dart";
import "package:takion/src/data/integrations/superhero/dto/superhero_search_response_dto.dart";

void main() {
  group("SuperHeroSearchResponseDto.fromJson", () {
    test("parses results with powerstats and image", () {
      final json = {
        "response": "success",
        "results-for": "batman",
        "results": [
          {
            "id": "70",
            "name": "Batman",
            "powerstats": {
              "intelligence": "100",
              "strength": "26",
              "speed": "27",
              "durability": "50",
              "power": "47",
              "combat": "100",
            },
            "image": {"url": "https://example.com/batman.jpg"},
          },
        ],
      };

      final dto = SuperHeroSearchResponseDto.fromJson(json);

      expect(dto.response, "success");
      expect(dto.resultsFor, "batman");
      expect(dto.results, hasLength(1));

      final character = dto.results.first;
      expect(character.id, 70);
      expect(character.name, "Batman");
      expect(character.imageUrl, "https://example.com/batman.jpg");

      final powerstats = character.powerstats!;
      expect(powerstats.intelligence, 100);
      expect(powerstats.strength, 26);
      expect(powerstats.speed, 27);
      expect(powerstats.durability, 50);
      expect(powerstats.power, 47);
      expect(powerstats.combat, 100);
    });

    test("parses numeric powerstats", () {
      final json = {
        "response": "success",
        "results": [
          {
            "id": "1",
            "name": "A-Bomb",
            "powerstats": {
              "intelligence": 38,
              "strength": 100,
              "speed": 17,
              "durability": 80,
              "power": 24,
              "combat": 64,
            },
            "image": {"url": "https://example.com/abomb.jpg"},
          },
        ],
      };

      final character = SuperHeroSearchResponseDto.fromJson(json).results.first;
      expect(character.powerstats!.intelligence, 38);
      expect(character.powerstats!.strength, 100);
    });

    test('treats "null" powerstats values as null', () {
      final json = {
        "response": "success",
        "results": [
          {
            "id": "1",
            "name": "Test Hero",
            "powerstats": {
              "intelligence": "null",
              "strength": "50",
              "speed": "null",
              "durability": "40",
              "power": "null",
              "combat": "30",
            },
            "image": {"url": ""},
          },
        ],
      };

      final character = SuperHeroSearchResponseDto.fromJson(json).results.first;
      final powerstats = character.powerstats!;
      expect(powerstats.intelligence, isNull);
      expect(powerstats.strength, 50);
      expect(powerstats.speed, isNull);
      expect(powerstats.durability, 40);
      expect(powerstats.power, isNull);
      expect(powerstats.combat, 30);
      expect(character.imageUrl, isNull);
    });

    test("handles error response with no results", () {
      final json = {
        "response": "error",
        "error": "character with given name not found",
      };

      final dto = SuperHeroSearchResponseDto.fromJson(json);
      expect(dto.response, "error");
      expect(dto.results, isEmpty);
    });

    test("toEntity maps to domain entity", () {
      final json = {
        "response": "success",
        "results": [
          {
            "id": "70",
            "name": "Batman",
            "powerstats": {
              "intelligence": "100",
              "strength": "26",
              "speed": "27",
              "durability": "50",
              "power": "47",
              "combat": "100",
            },
            "image": {"url": "https://example.com/batman.jpg"},
          },
        ],
      };

      final entity = SuperHeroSearchResponseDto.fromJson(
        json,
      ).results.first.toEntity();
      expect(entity.id, 70);
      expect(entity.name, "Batman");
      expect(entity.powerstats!.combat, 100);
    });
  });
}
