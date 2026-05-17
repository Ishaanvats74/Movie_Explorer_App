import 'package:flutter/material.dart';

class OverviewSection extends StatelessWidget {
  final Map<String, dynamic> movie;
  const OverviewSection({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final overview = movie['overview'] ?? "No overview available.";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "OVERVIEW",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            overview,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14.5,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}
