import 'package:flutter/material.dart';
import 'search_screen.dart';
import '../services/movie_service.dart';
import '../widgets/media_section.dart';
import '../screens/movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List trendingMovies = [];
  List topRatedMovies = [];
  List upcomingMovies = [];
  List trendingTV = [];
  List topRatedTV = [];
  List popularTV = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final responses = await Future.wait([
        MovieService().getTrendingMovies(),
        MovieService().getTopRatedMovies(),
        MovieService().getUpcomingMovies(),
        MovieService().getTrendingTV(),
        MovieService().getTopRatedTV(),
        MovieService().getPopularTV(),
      ]);
      setState(() {
        trendingMovies = responses[0];
        topRatedMovies = responses[1];
        upcomingMovies = responses[2];
        trendingTV = responses[3];
        topRatedTV = responses[4];
        popularTV = responses[5];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : CustomScrollView(
              slivers: [
                // ── Collapsing App Bar ──
                SliverAppBar(
                  expandedHeight: 0,
                  pinned: true,
                  backgroundColor: Colors.black,
                  elevation: 0,
                  title: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.movie_filter_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "MovieX",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero Featured Banner ──
                      if (trendingMovies.isNotEmpty)
                        _HeroBanner(movie: trendingMovies.first),

                      const SizedBox(height: 28),

                      MediaSection(
                        title: "Trending Movies",
                        items: trendingMovies,
                      ),
                      MediaSection(
                        title: "Top Rated Movies",
                        items: topRatedMovies,
                      ),
                      MediaSection(
                        title: "Upcoming Movies",
                        items: upcomingMovies,
                      ),
                      MediaSection(
                        title: "Trending TV Shows",
                        items: trendingTV,
                      ),
                      MediaSection(title: "Top Rated TV", items: topRatedTV),
                      MediaSection(title: "Popular TV", items: popularTV),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final Map movie;
  const _HeroBanner({required this.movie});

  @override
  Widget build(BuildContext context) {
    final backdrop = movie['backdrop_path'];
    final title = movie['title'] ?? movie['name'] ?? '';
    final rating = movie['vote_average']?.toStringAsFixed(1) ?? '';
    final year = (movie['release_date'] ?? '').toString().length >= 4
        ? movie['release_date'].toString().substring(0, 4)
        : '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(movieId: movie['id']),
        ),
      ),
      child: Stack(
        children: [
          // Image
          SizedBox(
            height: 380,
            width: double.infinity,
            child: backdrop != null
                ? Image.network(
                    "https://image.tmdb.org/t/p/w780$backdrop",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade900),
                  )
                : Container(color: Colors.grey.shade900),
          ),

          // Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.95),
                    Colors.black,
                  ],
                  stops: const [0.2, 0.5, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "FEATURED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.amber.shade400,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      year,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _HeroButton(
                      label: "Watch Now",
                      icon: Icons.play_arrow_rounded,
                      filled: true,
                    ),
                    const SizedBox(width: 10),
                    _HeroButton(
                      label: "More Info",
                      icon: Icons.info_outline_rounded,
                      filled: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: filled ? Colors.green.shade700 : Colors.white.withOpacity(0.12),
        border: filled ? null : Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
