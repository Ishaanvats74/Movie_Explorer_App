import 'package:flutter/material.dart';

import '../services/movie_service.dart';
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

  bool isLoading = true;

  String? error;

  @override
  void initState() {
    super.initState();

    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    try {
      final data = await MovieService().getMovieDetails(widget.movieId);

      setState(() {
        movie = data;

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
          movie?['title'] ?? '',

          style: const TextStyle(fontSize: 16),
        ),
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
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
                    // ───── HEADER ─────
                    DetailsHeader(movie: movie!),

                    // ───── OVERVIEW ─────
                    OverviewSection(movie: movie!),

                    // ───── BUTTONS ─────
                    DetailsButtons(movieId: widget.movieId),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
