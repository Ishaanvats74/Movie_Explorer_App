import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../widgets/cast_card.dart';
import '../widgets/details_buttons.dart';
import '../widgets/details_header.dart';
import '../widgets/overview_section.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  Map<String, dynamic>? movie;
  List cast = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    try {
      // Fetch movie details + cast at the same time
      final responses = await Future.wait([
        MovieService().getMovieDetails(widget.movieId),
        MovieService().getMovieCast(
          widget.movieId,
        ), // ← add this to MovieService
      ]);

      setState(() {
        movie = responses[0] as Map<String, dynamic>;
        cast = (responses[1] as List).take(15).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load movie";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        title: Text(
          movie?['title'] ?? movie?['name'] ?? '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : error != null
            ? Center(
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailsHeader(movie: movie!),
                    OverviewSection(movie: movie!),
                    DetailsButtons(
                      movieId: widget.movieId,
                      movieName: movie?['title'] ?? movie?['name'] ?? 'Trailer',
                      mediaType: 'movie',
                    ),

                    // ── Cast Section ──
                    if (cast.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: Text(
                          "CAST",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cast.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final member = cast[index];
                            final profilePath = member['profile_path'];
                            return CastCard(
                              name: member['name'] ?? '',
                              character: member['character'] ?? '',
                              imageUrl: profilePath != null
                                  ? "https://image.tmdb.org/t/p/w185$profilePath"
                                  : '',
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
