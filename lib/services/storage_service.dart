import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class StorageService {
  static const String _watchlistKey = 'movie_watchlist';

  Future<List<Movie>> getWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList(_watchlistKey) ?? [];

      return watchlistJson
          .map((movieJson) => Movie.fromJson(json.decode(movieJson)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addToWatchlist(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlist = await getWatchlist();

      // Check if movie is already in watchlist
      if (watchlist.any((m) => m.imdbID == movie.imdbID)) {
        return false; // Movie already exists
      }

      watchlist.add(movie);
      final watchlistJson = watchlist
          .map((movie) => json.encode(movie.toJson()))
          .toList();

      return await prefs.setStringList(_watchlistKey, watchlistJson);
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromWatchlist(String imdbId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlist = await getWatchlist();

      watchlist.removeWhere((movie) => movie.imdbID == imdbId);

      final watchlistJson = watchlist
          .map((movie) => json.encode(movie.toJson()))
          .toList();

      return await prefs.setStringList(_watchlistKey, watchlistJson);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isInWatchlist(String imdbId) async {
    try {
      final watchlist = await getWatchlist();
      return watchlist.any((movie) => movie.imdbID == imdbId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_watchlistKey);
    } catch (e) {
      return false;
    }
  }

  Future<int> getWatchlistCount() async {
    try {
      final watchlist = await getWatchlist();
      return watchlist.length;
    } catch (e) {
      return 0;
    }
  }
}
