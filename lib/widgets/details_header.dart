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

    final String title =
        widget.movie['title'] ?? widget.movie['name'] ?? "No Title";
    final String releaseYear = widget.movie['release_date'] != null
        ? widget.movie['release_date'].toString().substring(0, 4)
        : "N/A";
    final String runtime = widget.movie['runtime'] != null
        ? "${widget.movie['runtime']} min"
        : "N/A";
    final String rating = widget.movie['vote_average'] != null
        ? widget.movie['vote_average'].toStringAsFixed(1)
        : "N/A";
    final List genres = widget.movie['genres'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image carousel ──
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(0),
              ),
              child: SizedBox(
                height: 240,
                width: double.infinity,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: images.isEmpty ? 1 : images.length,
                  onPageChanged: (i) => setState(() => currentImageIndex = i),
                  itemBuilder: (context, index) {
                    if (images.isEmpty) {
                      return Container(color: Colors.grey.shade900);
                    }
                    return Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : Container(
                              color: Colors.grey.shade900,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white24,
                            size: 40,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Badges bottom-left
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _Badge(
                    icon: Icons.star_rounded,
                    label: rating,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 8),
                  _Badge(label: releaseYear),
                  const SizedBox(width: 8),
                  _Badge(label: runtime),
                  const Spacer(),
                  // Page dots
                  if (images.length > 1)
                    Row(
                      children: List.generate(images.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == currentImageIndex ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == currentImageIndex
                                ? Colors.green.shade400
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),

        // ── Title block ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              if (genres.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: genres.take(4).map<Widget>((g) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade900.withOpacity(0.5),
                        border: Border.all(
                          color: Colors.green.shade800,
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        g['name'] ?? '',
                        style: TextStyle(
                          color: Colors.green.shade300,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  const _Badge({required this.label, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color ?? Colors.white70),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
