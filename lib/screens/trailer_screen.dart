import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TrailerScreen extends StatefulWidget {
  final String videoKey;

  const TrailerScreen({
    super.key,
    required this.videoKey,
  });

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final YoutubeExplode _yt = YoutubeExplode();

  bool _isInitialized = false;
  bool _isFullScreen = false;
  bool _isMuted = false;
  bool _hasError = false;
  String _errorMessage = '';
  double _playbackSpeed = 1.0;

  final List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final manifest = await _yt.videos.streams.getManifest(
        widget.videoKey,
        ytClients: [
          YoutubeApiClient.ios,
          YoutubeApiClient.androidVr,
        ],
      );

      final streams = manifest.muxed.sortByVideoQuality();
      if (streams.isEmpty) {
        throw Exception('No playable stream found for this video.');
      }

      final streamInfo = streams.last;
      final videoUrl = streamInfo.url.toString();

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showOptions: false,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        progressIndicatorDelay: Platform.isAndroid
            ? const Duration(milliseconds: 500)
            : null,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.grey.shade600,
        ),
      );

      _chewieController!.addListener(_onChewieUpdate);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onChewieUpdate() {
    if (_chewieController == null) return;
    final isFullScreen = _chewieController!.isFullScreen;
    if (isFullScreen != _isFullScreen) {
      if (mounted) setState(() => _isFullScreen = isFullScreen);
    }
  }

  @override
  void dispose() {
    _chewieController?.removeListener(_onChewieUpdate);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _yt.close();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _isMuted
        ? _videoPlayerController?.setVolume(0)
        : _videoPlayerController?.setVolume(1);
  }

  void _seekBy(int seconds) {
    final current = _videoPlayerController?.value.position ?? Duration.zero;
    _videoPlayerController?.seekTo(current + Duration(seconds: seconds));
  }

  // ✅ Fixed: use setPlaybackSpeed on VideoPlayerController
  void _changeSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _videoPlayerController?.setPlaybackSpeed(speed);
    Navigator.pop(context);
  }

  void _showSpeedSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Playback Speed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._speeds.map((speed) {
              final isSelected = speed == _playbackSpeed;
              return ListTile(
                onTap: () => _changeSpeed(speed),
                leading: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.red : Colors.white54,
                ),
                title: Text(
                  '${speed}x',
                  style: TextStyle(
                    color: isSelected ? Colors.red : Colors.white,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Loading trailer...',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Failed to load trailer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initPlayer();
              },
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text('Retry', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [

          // ── Top bar (portrait only) ──
          if (!_isFullScreen)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Trailer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),

                    if (_isInitialized) ...[
                      // Mute toggle
                      IconButton(
                        onPressed: _toggleMute,
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                        ),
                      ),

                      // Speed selector
                      GestureDetector(
                        onTap: _showSpeedSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_playbackSpeed}x',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // ── Player area ──
          AspectRatio(
            aspectRatio: _isInitialized
                ? _videoPlayerController!.value.aspectRatio
                : 16 / 9,
            child: _hasError
                ? _buildError()
                : _isInitialized
                ? Chewie(controller: _chewieController!)
                : _buildLoader(),
          ),

          // ── Seek + Play/Pause controls (portrait only) ──
          if (!_isFullScreen && _isInitialized)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // Seek back 10s
                  _SeekButton(
                    icon: Icons.replay_10,
                    label: '-10s',
                    onTap: () => _seekBy(-10),
                  ),

                  // Play / Pause
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _videoPlayerController!,
                    builder: (context, value, _) {
                      return GestureDetector(
                        onTap: () {
                          value.isPlaying
                              ? _videoPlayerController!.pause()
                              : _videoPlayerController!.play();
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),

                  // Seek forward 10s
                  _SeekButton(
                    icon: Icons.forward_10,
                    label: '+10s',
                    onTap: () => _seekBy(10),
                  ),
                ],
              ),
            ),

          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

// ── Reusable seek button ──
class _SeekButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SeekButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}