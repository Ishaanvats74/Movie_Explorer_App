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
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movieId: movieId),
          ),
        );
      },

      child: Container(
        width: 160,

        decoration: BoxDecoration(
          color: Colors.grey.shade900,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: Colors.white10),

          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,

          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),

              child: Image.network(
                imageUrl,

                height: 220,

                width: double.infinity,

                fit: BoxFit.cover,

                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return Container(
                    height: 220,

                    color: Colors.grey.shade800,

                    child: const Center(child: CircularProgressIndicator()),
                  );
                },

                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,

                    color: Colors.grey.shade800,

                    child: const Center(
                      child: Icon(
                        Icons.broken_image,

                        color: Colors.white54,

                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(
                    height: 40,

                    child: Text(
                      title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 14,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),

                      const SizedBox(width: 4),

                      Text(
                        formattedRating,

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
