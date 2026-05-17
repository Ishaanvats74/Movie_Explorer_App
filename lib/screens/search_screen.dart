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
  Timer? debounce;

  @override
  void dispose() {
    debounce?.cancel();

    super.dispose();
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        movies = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

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

          return isValidType && hasImage && hasTitle && hasRating;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search Movies...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                ),
                onChanged: (value) {
                  if (debounce?.isActive ?? false) {
                    debounce!.cancel();
                  }

                  debounce = Timer(const Duration(milliseconds: 500), () {
                    hasSearched = true;
                    searchMovies(value);
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : movies.isEmpty
                    ? Center(
                        child: Text(
                          hasSearched
                              ? "No movies found"
                              : "Search for a movie",

                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : GridView.builder(
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
                                ? "https://image.tmdb.org/t/p/w500${movie["poster_path"] ?? movie["backdrop_path"]}"
                                : "https://via.placeholder.com/500x750",
                            rating: movie["vote_average"] != null
                                ? movie["vote_average"].toString()
                                : "N/A",
                            title:
                                movie["title"] ?? movie["name"] ?? "No Title",
                            movieId: movie['id'],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
