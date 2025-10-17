import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://www.omdbapi.com/';
  static final String _apiKey = dotenv.env['OMDB_API_KEY'] ?? '';

  Future<MovieSearchResponse> searchMovies(String query, {int page = 1}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?apikey=$_apiKey&s=$query&page=$page&type=movie',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MovieSearchResponse.fromJson(data);
      } else {
        return MovieSearchResponse(
          movies: [],
          totalResults: '0',
          response: false,
          error: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return MovieSearchResponse(
        movies: [],
        totalResults: '0',
        response: false,
        error: 'Network Error: $e',
      );
    }
  }

  Future<Movie?> getMovieDetails(String imdbId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?apikey=$_apiKey&i=$imdbId&plot=full',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Response'] == 'True') {
          return Movie.fromJson(data);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Movie>> getTrendingMovies() async {
    // Use broader queries to get more movies per search
    final queries = ['avengers', 'batman', 'star wars', 'marvel', 'disney', 'mission', 'transformers', 'spider', 'toy', 'matrix'];
    final List<Movie> trendingMovies = [];

    for (final query in queries) {
      final response = await searchMovies(query, page: 1);
      if (response.response && response.movies.isNotEmpty) {
        trendingMovies.addAll(response.movies);
        if (trendingMovies.length >= 25) break;
      }
      // Try page 2 for more results if needed
      if (trendingMovies.length < 25) {
        final response2 = await searchMovies(query, page: 2);
        if (response2.response && response2.movies.isNotEmpty) {
          trendingMovies.addAll(response2.movies);
          if (trendingMovies.length >= 25) break;
        }
      }
    }
    // Remove duplicates and limit to 25
    final uniqueMovies = <String, Movie>{};
    for (final movie in trendingMovies) {
      uniqueMovies[movie.imdbID] = movie;
      if (uniqueMovies.length >= 25) break;
    }
    return uniqueMovies.values.toList();
  }

}
