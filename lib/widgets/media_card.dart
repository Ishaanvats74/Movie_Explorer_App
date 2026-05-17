import 'package:flutter/material.dart';
import '../screens/movie_details_screen.dart';

class MediaCard extends StatelessWidget {
  final String title;
  final String rating;
  final String imageUrl;
  final int movieId;

  const MediaCard({
    super.key,
    required this.imageUrl,
    required this.rating,
    required this.title,
    required this.movieId,
  });

  @override
  Widget build(BuildContext context) {
    final formattedRating =
        double.tryParse(rating)?.toStringAsFixed(1) ?? "N/A";

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movieId)),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            height: 220,
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white24,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade400,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formattedRating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
