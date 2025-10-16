import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/animated_movie_grid.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onWatchlistChanged;

  const SearchScreen({Key? key, this.onWatchlistChanged}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
      _lastQuery = query;
    });

    try {
      final response = await _apiService.searchMovies(query.trim());

      if (mounted) {
        setState(() {
          _searchResults = response.movies;
          _isLoading = false;
          if (!response.response && response.error != null) {
            _error = response.error;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to search movies: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _hasSearched = false;
      _error = null;
      _lastQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: _buildSearchContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Movies',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your favorite movies',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.subTextColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppTheme.textColor),
        decoration: InputDecoration(
          hintText: 'Search for movies...',
          hintStyle: const TextStyle(color: AppTheme.subTextColor),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.subTextColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.clear,
              color: AppTheme.subTextColor,
            ),
            onPressed: _clearSearch,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onSubmitted: _searchMovies,
        onChanged: (value) {
          setState(() {}); // Rebuild to show/hide clear button
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSearchContent() {
    if (!_hasSearched) {
      return _buildEmptyState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        if (_hasSearched) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Results for "$_lastQuery"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.subTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!_isLoading && _searchResults.isNotEmpty)
                  Text(
                    '${_searchResults.length} found',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.subTextColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
        Expanded(
          child: AnimatedMovieGrid(
            movies: _searchResults,
            isLoading: _isLoading,
            onWatchlistChanged: widget.onWatchlistChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              size: 64,
              color: AppTheme.subTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Your Movie Search',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a movie title to find your next favorite film',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.subTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildQuickSearchButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickSearchButtons() {
    final quickSearches = ['Marvel', 'Batman', 'Star Wars', 'Disney', 'Comedy'];

    return Column(
      children: [
        Text(
          'Try these popular searches:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.subTextColor,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickSearches.map((search) {
            return GestureDetector(
              onTap: () {
                _searchController.text = search;
                _searchMovies(search);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  search,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Search Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error ?? 'Failed to search movies',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _searchMovies(_lastQuery),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
