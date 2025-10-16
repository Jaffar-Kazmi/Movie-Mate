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
    // Since OMDb doesn't have a trending endpoint, we'll search for popular movies
    final queries = ['avengers', 'batman', 'star wars', 'marvel', 'disney'];
    final List<Movie> trendingMovies = [];

    for (final query in queries) {
      final response = await searchMovies(query);
      if (response.response && response.movies.isNotEmpty) {
        // Take first 2 movies from each search to create a diverse trending list
        trendingMovies.addAll(response.movies.take(2));
      }
    }

    // Remove duplicates and return up to 10 movies
    final uniqueMovies = <String, Movie>{};
    for (final movie in trendingMovies) {
      uniqueMovies[movie.imdbID] = movie;
    }

    return uniqueMovies.values.take(10).toList();
  }
}
