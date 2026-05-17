import 'package:flutter/material.dart';
import '../screens/trailer_screen.dart';
import '../services/movie_service.dart';

class DetailsButtons extends StatelessWidget {
  final int movieId;
  final String movieName;
  final String mediaType;
  const DetailsButtons({
    super.key,
    required this.movieId,
    required this.movieName,
    required this.mediaType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _GradientButton(
              label: "Watch",
              icon: Icons.play_arrow_rounded,
              colors: [Colors.green.shade800, Colors.green.shade500],
              onPressed: () async {
                final String? imdbId = await MovieService().getImdbId(
                  movieId,
                  mediaType,
                );
                if (!context.mounted) return;
                if (imdbId != null) {
                  // final url = 'https://streamimdb.ru/embed/movie/$imdbId';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WatchScreen(imdbId: imdbId, movieName: movieName),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Watch not available")),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GradientButton(
              label: "Trailer",
              icon: Icons.movie_rounded,
              colors: [Colors.red.shade900, Colors.red.shade600],
              onPressed: () async {
                final trailerKey = await MovieService().getTrailerKey(movieId);
                if (trailerKey != null && context.mounted) {
                  final youtubeUrl =
                      'https://www.youtube.com/watch?v=$trailerKey';
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => TrailerScreen(
                  //       youtubeUrl: youtubeUrl,
                  //       movieName: movieName,
                  //     ),
                  //   ),
                  // );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Trailer not available")),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onPressed;
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
