import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../widgets/media_card.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List movies = [];
  bool isLoading = false;
  bool hasSearched = false;
  String selectedFilter = 'All';
  Timer? debounce;
  final TextEditingController _controller = TextEditingController();

  final List<String> filters = ['All', 'Movies', 'TV Shows'];

  @override
  void dispose() {
    debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() => movies = []);
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = await MovieService().searchMultiWithImdb(query);
      setState(() {
        movies = data.where((movie) {
          final mediaType = movie["media_type"];
          final isValidType = mediaType == "movie" || mediaType == "tv";
          final hasImage =
              movie["poster_path"] != null &&
              movie["poster_path"].toString().isNotEmpty;
          final hasTitle = (movie["title"] ?? movie["name"] ?? "")
              .toString()
              .trim()
              .isNotEmpty;
          final hasRating =
              movie["vote_average"] != null && movie["vote_average"] != 0;

          // Filter chip
          if (selectedFilter == 'Movies') {
            return isValidType &&
                hasImage &&
                hasTitle &&
                hasRating &&
                mediaType == 'movie';
          } else if (selectedFilter == 'TV Shows') {
            return isValidType &&
                hasImage &&
                hasTitle &&
                hasRating &&
                mediaType == 'tv';
          }
          return isValidType && hasImage && hasTitle && hasRating;
        }).toList();
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Movies, TV shows...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _controller.clear();
                              setState(() => movies = []);
                            },
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {}); // refresh suffix icon
                    if (debounce?.isActive ?? false) debounce!.cancel();
                    debounce = Timer(const Duration(milliseconds: 500), () {
                      hasSearched = true;
                      searchMovies(value);
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Filter chips ──
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = selectedFilter == filters[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedFilter = filters[i]);
                      if (hasSearched) searchMovies(_controller.text);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.green.shade700
                            : Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? Colors.green.shade700
                              : Colors.white10,
                        ),
                      ),
                      child: Text(
                        filters[i],
                        style: TextStyle(
                          color: active ? Colors.white : Colors.grey.shade400,
                          fontSize: 13,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Results ──
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                  : movies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasSearched
                                ? Icons.search_off_rounded
                                : Icons.movie_filter_outlined,
                            color: Colors.white12,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            hasSearched
                                ? "No results found"
                                : "Search for movies\nor TV shows",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.54,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MediaCard(
                          imageUrl: movie["poster_path"] != null
                              ? "https://image.tmdb.org/t/p/w500${movie["poster_path"]}"
                              : "https://via.placeholder.com/500x750",
                          rating: movie["vote_average"]?.toString() ?? "N/A",
                          title: movie["title"] ?? movie["name"] ?? "No Title",
                          movieId: movie['id'],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
