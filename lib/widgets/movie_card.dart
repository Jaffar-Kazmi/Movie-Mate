import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/storage_service.dart';
import '../screens/movie_detail_screen.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onWatchlistChanged;

  const MovieCard({
    Key? key,
    required this.movie,
    this.onWatchlistChanged,
  }) : super(key: key);

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
    with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInWatchlist = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _checkWatchlistStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    bool success;
    if (_isInWatchlist) {
      success = await _storageService.removeFromWatchlist(widget.movie.imdbID);
    } else {
      success = await _storageService.addToWatchlist(widget.movie);
    }

    if (success && mounted) {
      setState(() {
        _isInWatchlist = !_isInWatchlist;
        _isLoading = false;
      });

      widget.onWatchlistChanged?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInWatchlist
                ? '${widget.movie.title} added to watchlist'
                : '${widget.movie.title} removed from watchlist',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: _isInWatchlist ? Colors.green : Colors.red,
        ),
      );
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movie: widget.movie,
          onWatchlistChanged: widget.onWatchlistChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToDetails,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              margin: const EdgeInsets.all(4), // Reduced margin
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4, // Increased flex to give more space to poster
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: widget.movie.poster.isNotEmpty &&
                              widget.movie.poster != 'N/A'
                              ? CachedNetworkImage(
                            imageUrl: widget.movie.poster,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              child: const Icon(
                                Icons.movie,
                                size: 40, // Reduced icon size
                                color: Colors.grey,
                              ),
                            ),
                          )
                              : Container(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                size: 40, // Reduced icon size
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4, // Reduced top position
                          right: 4, // Reduced right position
                          child: GestureDetector(
                            onTap: _toggleWatchlist,
                            child: Container(
                              padding: const EdgeInsets.all(6), // Reduced padding
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 12, // Reduced size
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              )
                                  : Icon(
                                _isInWatchlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isInWatchlist
                                    ? Colors.red
                                    : Colors.white,
                                size: 16, // Reduced icon size
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(6), // Reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.movie.title,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith( // Changed from titleMedium
                              fontWeight: FontWeight.w600,
                              fontSize: 11, // Smaller font size
                            ),
                            maxLines: 2, // Allow 2 lines for title
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2), // Reduced spacing
                          Text(
                            widget.movie.year,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10, // Smaller font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
