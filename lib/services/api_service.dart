import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import 'dart:math';

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
    final queries = ['avengers', 'batman', 'star wars', 'marvel', 'disney', 'mission','the lord of rings', 'transformers', 'spider', 'toy', 'matrix', 'harry potter'];
    queries.shuffle(Random()); // Shuffle for randomness
    final List<Movie> trendingMovies = [];
    final random = Random();

    for (final query in queries) {
      int randomPage = 1 + random.nextInt(5); // Randomly pick page 1 or 2
      final response = await searchMovies(query, page: randomPage);
      if (response.response && response.movies.isNotEmpty) {
        trendingMovies.addAll(response.movies);
        if (trendingMovies.length >= 25) break;
      }
    }
    // Remove duplicates, limit to 25
    final uniqueMovies = <String, Movie>{};
    for (final movie in trendingMovies) {
      uniqueMovies[movie.imdbID] = movie;
      if (uniqueMovies.length >= 25) break;
    }
    return uniqueMovies.values.toList();
  }

}
