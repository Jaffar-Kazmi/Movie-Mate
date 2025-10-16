import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/storage_service.dart';
import '../widgets/animated_movie_grid.dart';
import '../theme/app_theme.dart';

class WatchlistScreen extends StatefulWidget {
  final VoidCallback? onWatchlistChanged;

  const WatchlistScreen({Key? key, this.onWatchlistChanged}) : super(key: key);

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final StorageService _storageService = StorageService();
  List<Movie> _watchlistMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await _storageService.getWatchlist();
      if (mounted) {
        setState(() {
          _watchlistMovies = movies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearWatchlist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Clear Watchlist',
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: const Text(
          'Are you sure you want to remove all movies from your watchlist?',
          style: TextStyle(color: AppTheme.subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.subTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _storageService.clearWatchlist();
      if (success) {
        await _loadWatchlist();
        widget.onWatchlistChanged?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Watchlist cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _onWatchlistChanged() {
    _loadWatchlist();
    widget.onWatchlistChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Watchlist',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _isLoading
                          ? 'Loading...'
                          : '${_watchlistMovies.length} movies saved',
                      key: ValueKey(_watchlistMovies.length),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.subTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (_watchlistMovies.isNotEmpty && !_isLoading)
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: AppTheme.textColor,
                    ),
                  ),
                  color: AppTheme.surfaceColor,
                  onSelected: (value) {
                    if (value == 'clear') {
                      _clearWatchlist();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(
                            Icons.clear_all,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Clear All',
                            style: TextStyle(color: AppTheme.textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_watchlistMovies.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadWatchlist,
      child: Column(
        children: [
          if (_watchlistMovies.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.secondaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 16,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Saved Movies',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: AnimatedMovieGrid(
              movies: _watchlistMovies,
              onWatchlistChanged: _onWatchlistChanged,
            ),
          ),
        ],
      ),
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
              Icons.bookmark_border,
              size: 64,
              color: AppTheme.subTextColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Watchlist is Empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start adding movies to your watchlist by searching and tapping the heart icon',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _buildQuickActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Switch to search tab (handled by parent widget)
            DefaultTabController.of(context)?.animateTo(1);
          },
          icon: const Icon(Icons.search),
          label: const Text('Search Movies'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            // Switch to home tab (handled by parent widget)
            DefaultTabController.of(context)?.animateTo(0);
          },
          icon: const Icon(Icons.home),
          label: const Text('Browse Trending'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.subTextColor,
          ),
        ),
      ],
    );
  }
}
