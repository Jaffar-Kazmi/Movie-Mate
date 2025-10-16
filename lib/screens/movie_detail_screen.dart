import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onWatchlistChanged;

  const MovieDetailScreen({
    Key? key,
    required this.movie,
    this.onWatchlistChanged,
  }) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Movie? _detailMovie;
  bool _isLoading = true;
  bool _isInWatchlist = false;
  bool _isWatchlistLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _loadMovieDetails();
    _checkWatchlistStatus();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final details = await _apiService.getMovieDetails(widget.movie.imdbID);
      if (mounted) {
        setState(() {
          _detailMovie = details ?? widget.movie;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detailMovie = widget.movie;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkWatchlistStatus() async {
    final isInWatchlist = await _storageService.isInWatchlist(widget.movie.imdbID);
    if (mounted) {
      setState(() {
        _isInWatchlist = isInWatchlist;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    if (_isWatchlistLoading) return;

    setState(() {
      _isWatchlistLoading = true;
    });

    bool success;
    if (_isInWatchlist) {
      success = await _storageService.removeFromWatchlist(widget.movie.imdbID);
    } else {
      success = await _storageService.addToWatchlist(_detailMovie ?? widget.movie);
    }

    if (success && mounted) {
      setState(() {
        _isInWatchlist = !_isInWatchlist;
        _isWatchlistLoading = false;
      });

      widget.onWatchlistChanged?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInWatchlist
                ? 'Added to watchlist'
                : 'Removed from watchlist',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: _isInWatchlist ? Colors.green : Colors.red,
        ),
      );
    } else if (mounted) {
      setState(() {
        _isWatchlistLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = _detailMovie ?? widget.movie;

    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(movie),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildMovieDetails(movie),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Movie movie) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            movie.poster.isNotEmpty && movie.poster != 'N/A'
                ? CachedNetworkImage(
              imageUrl: movie.poster,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppTheme.primaryColor,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.primaryColor,
                child: const Icon(
                  Icons.movie,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            )
                : Container(
              color: AppTheme.primaryColor,
              child: const Icon(
                Icons.movie,
                size: 80,
                color: Colors.grey,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _toggleWatchlist,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: _isWatchlistLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Icon(
                _isInWatchlist
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _isInWatchlist ? Colors.red : Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieDetails(Movie movie) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(movie),
          const SizedBox(height: 24),
          _buildInfoCards(movie),
          const SizedBox(height: 24),
          if (movie.plot != null && movie.plot!.isNotEmpty && movie.plot != 'N/A')
            _buildPlotSection(movie),
          const SizedBox(height: 24),
          _buildActionButton(movie),
        ],
      ),
    );
  }

  Widget _buildTitleSection(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                movie.year,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (movie.imdbRating != null && movie.imdbRating != 'N/A') ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.imdbRating!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards(Movie movie) {
    final info = <String, String>{};

    if (movie.genre != null && movie.genre!.isNotEmpty && movie.genre != 'N/A') {
      info['Genre'] = movie.genre!;
    }
    if (movie.director != null && movie.director!.isNotEmpty && movie.director != 'N/A') {
      info['Director'] = movie.director!;
    }
    if (movie.actors != null && movie.actors!.isNotEmpty && movie.actors != 'N/A') {
      info['Cast'] = movie.actors!;
    }
    if (movie.runtime != null && movie.runtime!.isNotEmpty && movie.runtime != 'N/A') {
      info['Runtime'] = movie.runtime!;
    }
    if (movie.released != null && movie.released!.isNotEmpty && movie.released != 'N/A') {
      info['Released'] = movie.released!;
    }

    if (info.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Movie Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...info.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildPlotSection(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plot',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            movie.plot!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textColor,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(Movie movie) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isWatchlistLoading ? null : _toggleWatchlist,
        icon: _isWatchlistLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(
          _isInWatchlist ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
        label: Text(
          _isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isInWatchlist ? Colors.red : AppTheme.secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
