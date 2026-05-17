import 'package:flutter/material.dart';

class DetailsHeader extends StatefulWidget {
  final Map<String, dynamic> movie;

  const DetailsHeader({super.key, required this.movie});

  @override
  State<DetailsHeader> createState() => _DetailsHeaderState();
}

class _DetailsHeaderState extends State<DetailsHeader> {
  int currentImageIndex = 0;

  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      if (widget.movie['backdrop_path'] != null)
        "https://image.tmdb.org/t/p/w780${widget.movie['backdrop_path']}",

      if (widget.movie['poster_path'] != null)
        "https://image.tmdb.org/t/p/w500${widget.movie['poster_path']}",
    ];

    final String releaseYear = widget.movie['release_date'] != null
        ? widget.movie['release_date'].toString().substring(0, 4)
        : "N/A";

    final String runtime = widget.movie['runtime'] != null
        ? "${widget.movie['runtime']} min"
        : "N/A";

    final String rating = widget.movie['vote_average'] != null
        ? widget.movie['vote_average'].toStringAsFixed(1)
        : "N/A";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Stack(
          alignment: Alignment.bottomCenter,

          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),

              child: SizedBox(
                height: 220,
                width: double.infinity,

                child: PageView.builder(
                  controller: pageController,

                  itemCount: images.length,

                  onPageChanged: (index) {
                    setState(() {
                      currentImageIndex = index;
                    });
                  },

                  itemBuilder: (context, index) {
                    return Image.network(
                      images[index],

                      fit: BoxFit.cover,

                      loadingBuilder: (context, child, progress) {
                        if (progress == null) {
                          return child;
                        }

                        return Container(
                          color: Colors.grey.shade800,

                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },

                      errorBuilder: (context, error, stackTrace) {
                        return Container(
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
                    );
                  },
                ),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,

                      end: Alignment.bottomCenter,

                      colors: [
                        Colors.transparent,

                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (images.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: List.generate(images.length, (index) {
                    final isActive = index == currentImageIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      margin: const EdgeInsets.symmetric(horizontal: 4),

                      width: isActive ? 20 : 8,

                      height: 8,

                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.shade400
                            : Colors.white38,

                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                widget.movie['title'] ?? "No Title",

                style: const TextStyle(
                  color: Colors.white,

                  fontSize: 28,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),

                  const SizedBox(width: 5),

                  Text(rating, style: const TextStyle(color: Colors.white)),

                  const SizedBox(width: 16),

                  Text(
                    releaseYear,

                    style: TextStyle(color: Colors.grey.shade400),
                  ),

                  const SizedBox(width: 16),

                  Text(runtime, style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
