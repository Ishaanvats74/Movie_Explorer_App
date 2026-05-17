import 'package:flutter/material.dart';

class OverviewSection extends StatelessWidget {
  final Map<String, dynamic> movie;

  const OverviewSection({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final overview = movie['overview'] ?? "No overview available.";

    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Overview",

            style: TextStyle(
              color: Colors.white,

              fontSize: 20,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            overview,

            style: const TextStyle(
              color: Colors.white70,

              fontSize: 15,

              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
