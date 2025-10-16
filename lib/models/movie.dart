class Movie {
  final String imdbID;
  final String title;
  final String year;
  final String type;
  final String poster;
  final String? plot;
  final String? genre;
  final String? director;
  final String? actors;
  final String? runtime;
  final String? imdbRating;
  final String? released;

  Movie({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.type,
    required this.poster,
    this.plot,
    this.genre,
    this.director,
    this.actors,
    this.runtime,
    this.imdbRating,
    this.released,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      imdbID: json['imdbID'] ?? '',
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      type: json['Type'] ?? '',
      poster: json['Poster'] ?? '',
      plot: json['Plot'],
      genre: json['Genre'],
      director: json['Director'],
      actors: json['Actors'],
      runtime: json['Runtime'],
      imdbRating: json['imdbRating'],
      released: json['Released'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imdbID': imdbID,
      'Title': title,
      'Year': year,
      'Type': type,
      'Poster': poster,
      'Plot': plot,
      'Genre': genre,
      'Director': director,
      'Actors': actors,
      'Runtime': runtime,
      'imdbRating': imdbRating,
      'Released': released,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Movie && other.imdbID == imdbID;
  }

  @override
  int get hashCode => imdbID.hashCode;

  @override
  String toString() {
    return 'Movie(imdbID: $imdbID, title: $title, year: $year)';
  }
}

class MovieSearchResponse {
  final List<Movie> movies;
  final String totalResults;
  final bool response;
  final String? error;

  MovieSearchResponse({
    required this.movies,
    required this.totalResults,
    required this.response,
    this.error,
  });

  factory MovieSearchResponse.fromJson(Map<String, dynamic> json) {
    if (json['Response'] == 'False') {
      return MovieSearchResponse(
        movies: [],
        totalResults: '0',
        response: false,
        error: json['Error'],
      );
    }

    final List<dynamic> searchResults = json['Search'] ?? [];
    final List<Movie> movies = searchResults
        .map((movieJson) => Movie.fromJson(movieJson))
        .toList();

    return MovieSearchResponse(
      movies: movies,
      totalResults: json['totalResults'] ?? '0',
      response: json['Response'] == 'True',
    );
  }
}
