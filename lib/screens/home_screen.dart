import 'package:flutter/material.dart';

import 'search_screen.dart';

import '../services/movie_service.dart';

import '../widgets/media_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List trendingMovies = [];

  List topRatedMovies = [];

  List upcomingMovies = [];

  List trendingTV = [];

  List topRatedTV = [];

  List popularTV = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final responses = await Future.wait([
        MovieService().getTrendingMovies(),

        MovieService().getTopRatedMovies(),

        MovieService().getUpcomingMovies(),

        MovieService().getTrendingTV(),

        MovieService().getTopRatedTV(),

        MovieService().getPopularTV(),
      ]);

      setState(() {
        trendingMovies = responses[0];

        topRatedMovies = responses[1];

        upcomingMovies = responses[2];

        trendingTV = responses[3];

        topRatedTV = responses[4];

        popularTV = responses[5];

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Movie Explorer"),

        centerTitle: true,

        backgroundColor: Colors.green.shade900,

        foregroundColor: Colors.white,

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },

            icon: const Icon(Icons.search),
          ),
        ],
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    MediaSection(
                      title: "Trending Movies",

                      items: trendingMovies,
                    ),

                    MediaSection(
                      title: "Top Rated Movies",

                      items: topRatedMovies,
                    ),

                    MediaSection(
                      title: "Upcoming Movies",

                      items: upcomingMovies,
                    ),

                    MediaSection(title: "Trending TV Shows", items: trendingTV),

                    MediaSection(title: "Top Rated TV", items: topRatedTV),

                    MediaSection(title: "Popular TV", items: popularTV),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
