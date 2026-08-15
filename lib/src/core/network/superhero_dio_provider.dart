import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

const Map<String, String> superHeroImageHeaders = {
  "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Accept":
      "image/avif,image/webp,image/apng,image/*,*/*;q=0.8,application/octet-stream;q=0.1",
};

final superheroDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: "https://superheroapi.com/api/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) =>
          status != null && ((status >= 200 && status < 300) || status == 304),
    ),
  );
});
