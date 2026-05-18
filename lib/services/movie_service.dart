import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieService {
  final Dio dio = Dio();

  final token = dotenv.env['TMDB_API_KEY'];
  final baseUrl = 'https://api.themoviedb.org/3';

  Options get options => Options(headers: {"Authorization": "Bearer $token"});

  Future<List<dynamic>> getTrendingMovies() async {
    final response = await dio.get(
      "$baseUrl/trending/movie/day",
      options: options,
    );

    return response.data["results"];
  }

  Future<List<dynamic>> getPopularMovies() async {
    final response = await dio.get("$baseUrl/movie/popular", options: options);

    return response.data['results'];
  }

  Future<List<dynamic>> getTopRatedMovies() async {
    final response = await dio.get(
      "$baseUrl/movie/top_rated",
      options: options,
    );

    return response.data['results'];
  }

  Future<List<dynamic>> getMovieCast(int movieId) async {
    final response = await dio.get(
      "$baseUrl/movie/$movieId/credits",
      options: options,
    );

    return response.data["cast"];
  }

  Future<List<dynamic>> getRecommendedMovies(int movieId) async {
    final response = await dio.get(
      "$baseUrl/movie/$movieId/recommendations",
      options: options,
    );

    return response.data["results"];
  }

  Future<List<dynamic>> getMovieVideos(int movieId) async {
    final response = await dio.get(
      "$baseUrl/movie/$movieId/videos",
      options: options,
    );

    return response.data["results"];
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final response = await dio.get("$baseUrl/movie/$movieId", options: options);

    return response.data;
  }

  Future<List<dynamic>> getUpcomingMovies() async {
    final response = await dio.get('$baseUrl/movie/upcoming', options: options);
    return response.data['results'];
  }

  Future<List<dynamic>> getPopularTV() async {
    final response = await dio.get("$baseUrl/tv/popular", options: options);

    return response.data["results"];
  }

  Future<List<dynamic>> getTrendingTV() async {
    final response = await dio.get(
      "$baseUrl/trending/tv/day",
      options: options,
    );

    return response.data["results"];
  }

  Future<List<dynamic>> getTopRatedTV() async {
    final response = await dio.get("$baseUrl/tv/top_rated", options: options);

    return response.data["results"];
  }

  Future<Map<String, dynamic>> getTVDetails(int tvId) async {
    final response = await dio.get("$baseUrl/tv/$tvId", options: options);

    return response.data;
  }

  Future<List<dynamic>> getTVCast(int tvId) async {
    final response = await dio.get(
      "$baseUrl/tv/$tvId/credits",
      options: options,
    );

    return response.data["cast"];
  }

  Future<List<dynamic>> getRecommendedTV(int tvId) async {
    final response = await dio.get(
      "$baseUrl/tv/$tvId/recommendations",
      options: options,
    );

    return response.data["results"];
  }

  Future<List<dynamic>> getTVVideos(int tvId) async {
    final response = await dio.get(
      "$baseUrl/tv/$tvId/videos",
      options: options,
    );

    return response.data["results"];
  }

  // ===========================
  // SEARCH MULTI
  // ===========================

  Future<List<dynamic>> searchMulti(String query) async {
    final response = await dio.get(
      "$baseUrl/search/multi",
      options: options,
      queryParameters: {"query": query},
    );

    return response.data["results"];
  }

  // ===========================
  // GET IMDB ID
  // ===========================

  Future<String?> getImdbId(int id, String mediaType) async {
    try {
      Response response;

      if (mediaType == "movie") {
        response = await dio.get(
          "$baseUrl/movie/$id/external_ids",
          options: options,
        );
      } else if (mediaType == "tv") {
        response = await dio.get(
          "$baseUrl/tv/$id/external_ids",
          options: options,
        );
      } else {
        return null;
      }

      return response.data["imdb_id"];
    } catch (e) {
      print("IMDb ID Error: $e");
      return null;
    }
  }

  // ===========================
  // SEARCH WITH IMDB IDS
  // ===========================

  Future<List<dynamic>> searchMultiWithImdb(String query) async {
    final results = await searchMulti(query);

    for (var item in results) {
      final mediaType = item["media_type"];

      if (mediaType == "movie" || mediaType == "tv") {
        final imdbId = await getImdbId(item["id"], mediaType);

        item["imdb_id"] = imdbId;
      }
    }

    return results;
  }

  Future<String?> getTrailerKey(int movieId) async {
    final videos = await getMovieVideos(movieId);

    for (var video in videos) {
      if (video["site"] == "YouTube" &&
          video["type"] == "Trailer") {
        return video["key"];
      }
    }

    return null;
  }
}
