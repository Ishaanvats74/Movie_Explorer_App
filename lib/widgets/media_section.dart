import 'package:flutter/material.dart';

import 'media_card.dart';

class MediaSection extends StatelessWidget {
  final String title;

  final List items;

  const MediaSection({super.key, required this.items, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                title,

                style: const TextStyle(
                  color: Colors.white,

                  fontSize: 24,

                  fontWeight: FontWeight.bold,
                ),
              ),

              TextButton(onPressed: () {}, child: const Text("See All")),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 320,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            padding: const EdgeInsets.symmetric(horizontal: 16),

            itemCount: items.length,

            separatorBuilder: (context, index) {
              return const SizedBox(width: 16);
            },

            itemBuilder: (context, index) {
              final item = items[index];

              return MediaCard(
                movieId: item["id"],

                title: item["title"] ?? item["name"] ?? "No Title",

                rating: item["vote_average"].toString(),

                imageUrl: item["poster_path"] != null
                    ? "https://image.tmdb.org/t/p/w500${item["poster_path"]}"
                    : "https://via.placeholder.com/500x750",
              );
            },
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
