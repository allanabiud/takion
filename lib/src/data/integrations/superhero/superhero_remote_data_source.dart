import "package:dio/dio.dart";
import "package:takion/src/data/integrations/superhero/dto/superhero_search_response_dto.dart";

abstract interface class SuperHeroRemoteDataSource {
  Future<SuperHeroSearchResponseDto> search(String token, String name);
}

class SuperHeroRemoteDataSourceImpl implements SuperHeroRemoteDataSource {
  SuperHeroRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<SuperHeroSearchResponseDto> search(String token, String name) async {
    final response = await _dio.get(
      "$token/search/${Uri.encodeComponent(name)}",
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return SuperHeroSearchResponseDto.fromJson(data);
    }
    return const SuperHeroSearchResponseDto(response: "error");
  }
}
