import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  final String genre;

  const GenreChip({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.green.shade700,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        genre,

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

        style: const TextStyle(
          color: Colors.white,

          fontWeight: FontWeight.w600,

          fontSize: 13,
        ),
      ),
    );
  }
}
