import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TrailerScreen extends StatelessWidget {
  final String youtubeUrl;
  final String movieName;
  const TrailerScreen({
    super.key,
    required this.youtubeUrl,
    required this.movieName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        title: Text('$movieName Trailer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          VideoPlayerView(youtubeUrl: youtubeUrl, movieName: movieName),
        ],
      ),
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  final String youtubeUrl;
  final String movieName;
  const VideoPlayerView({
    super.key,
    required this.youtubeUrl,
    required this.movieName,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final yt = YoutubeExplode();
    try {
      final videoId = VideoId(widget.youtubeUrl);
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.muxed.sortByVideoQuality().last;

      _videoPlayerController = VideoPlayerController.networkUrl(streamInfo.url);

      _chewieController = ChewieController(
        autoInitialize: true,
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 16 / 9,
        allowPlaybackSpeedChanging: true,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading video: $e');
    } finally {
      yt.close();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.movieName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Divider(),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _isLoading
              ? const ColoredBox(
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Chewie(controller: _chewieController!),
        ),
      ],
    );
  }
}
