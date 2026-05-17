import 'package:flutter/material.dart';

class CastCard extends StatelessWidget {
  final String name;

  final String character;

  final String imageUrl;

  const CastCard({
    super.key,
    required this.name,
    required this.character,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          CircleAvatar(
            radius: 40,

            backgroundColor: Colors.grey.shade800,

            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,

            child: imageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white54)
                : null,
          ),

          const SizedBox(height: 10),

          Text(
            name,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            character,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            textAlign: TextAlign.center,

            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
