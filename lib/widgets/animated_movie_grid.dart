import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/movie.dart';
import 'movie_card.dart';

class AnimatedMovieGrid extends StatefulWidget {
  final List<Movie> movies;
  final VoidCallback? onWatchlistChanged;
  final bool isLoading;

  const AnimatedMovieGrid({
    Key? key,
    required this.movies,
    this.onWatchlistChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AnimatedMovieGrid> createState() => _AnimatedMovieGridState();
}

class _AnimatedMovieGridState extends State<AnimatedMovieGrid> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No movies found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for a different movie',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.movies.length} movies found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isGridView ? Icons.view_list : Icons.grid_view,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isGridView
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildGridView(),
            secondChild: _buildListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(4), // Reduced padding
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Changed from 2 to 3 cards per row
          childAspectRatio: 0.6, // Changed from 0.7 to 0.6 for more compact cards
          crossAxisSpacing: 4, // Reduced spacing
          mainAxisSpacing: 4, // Reduced spacing
        ),
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 3, // Updated to match crossAxisCount
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: MovieCard(
                  movie: widget.movies[index],
                  onWatchlistChanged: widget.onWatchlistChanged,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(4), // Reduced padding
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2), // Reduced margin
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8), // Reduced padding
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6), // Smaller radius
                        child: widget.movies[index].poster.isNotEmpty &&
                            widget.movies[index].poster != 'N/A'
                            ? Image.network(
                          widget.movies[index].poster,
                          width: 50, // Reduced from 60
                          height: 65, // Reduced from 80
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 65,
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              child: const Icon(Icons.movie, color: Colors.grey, size: 20),
                            );
                          },
                        )
                            : Container(
                          width: 50,
                          height: 65,
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          child: const Icon(Icons.movie, color: Colors.grey, size: 20),
                        ),
                      ),
                      title: Text(
                        widget.movies[index].title,
                        style: Theme.of(context).textTheme.titleSmall, // Changed from titleMedium
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            'Year: ${widget.movies[index].year}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (widget.movies[index].genre != null) ...[
                            const SizedBox(height: 1),
                            Text(
                              'Genre: ${widget.movies[index].genre}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        // Navigate to movie details (handled by MovieCard)
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
