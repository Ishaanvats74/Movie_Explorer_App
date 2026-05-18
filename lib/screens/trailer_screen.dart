import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TrailerScreen extends StatelessWidget {
  final String youtubeUrl;
  final String movieName;
  const TrailerScreen({super.key, required this.youtubeUrl, required this.movieName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "TRAILER",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade400,  
                letterSpacing: 1.5,
              ),
            ),
            Text(
              movieName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Player ──
          VideoPlayerView(youtubeUrl: youtubeUrl, movieName: movieName),

          // ── Info below player ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movieName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade900.withOpacity(0.5),
                        border: Border.all(color: Colors.green.shade800, width: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Official Trailer",  // ✅ only difference from WatchScreen
                        style: TextStyle(
                          color: Colors.green.shade300,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "YouTube",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.06)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── VideoPlayerView — unchanged ──
class VideoPlayerView extends StatefulWidget {
  final String youtubeUrl;
  final String movieName;
  const VideoPlayerView({super.key, required this.youtubeUrl, required this.movieName});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

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
      debugPrint('🎬 Video ID: $videoId');
      debugPrint('🎬 Video ID: $streamInfo');
      _videoPlayerController = VideoPlayerController.networkUrl(streamInfo.url);

      _chewieController = ChewieController(
        autoInitialize: true,
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 16 / 9,
        allowPlaybackSpeedChanging: true,
        autoPlay: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.green.shade500,
          handleColor: Colors.green.shade400,
          backgroundColor: Colors.white12,
          bufferedColor: Colors.white24,
        ),
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load trailer';
        });
      }
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _isLoading
          ? Container(
              color: Colors.grey.shade900,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.green.shade400, strokeWidth: 2),
                    const SizedBox(height: 12),
                    Text(
                      "Loading trailer...",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          : _error != null
              ? Container(
                  color: Colors.grey.shade900,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                        const SizedBox(height: 10),
                        Text(_error!, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              : Chewie(controller: _chewieController!),
    );
  }
}