import 'package:flutter/material.dart';

import '../screens/trailer_screen.dart';
import '../services/movie_service.dart';

class DetailsButtons extends StatelessWidget {
  final int movieId;
  final String movieName;
  const DetailsButtons({super.key, required this.movieId, required this.movieName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      child: Row(
        children: [
          // WATCH BUTTON
          Expanded(
            child: SizedBox(
              height: 50,

              child: ElevatedButton.icon(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  elevation: 4,

                  backgroundColor: Colors.green.shade700,

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                icon: const Icon(Icons.play_arrow),

                label: const Text("Watch"),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // TRAILER BUTTON
          Expanded(
            child: SizedBox(
              height: 50,

              child: ElevatedButton.icon(
                // TRAILER BUTTON
                onPressed: () async {
                  final trailerKey = await MovieService().getTrailerKey(
                    movieId,
                  );

                  if (trailerKey != null && context.mounted) {
                    // Convert key to full YouTube URL
                    final youtubeUrl =
                        'https://www.youtube.com/watch?v=$trailerKey';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrailerScreen(youtubeUrl: youtubeUrl,movieName: movieName),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Trailer not available")),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  elevation: 4,

                  backgroundColor: Colors.red.shade700,

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                icon: const Icon(Icons.movie),

                label: const Text("Trailer"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
