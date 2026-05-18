import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MovieScreen extends StatefulWidget {
  final String imdbId;
  final String movieName;
  const MovieScreen({super.key, required this.imdbId, required this.movieName});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  bool _isLoading = true;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _webViewController?.stopLoading();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

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
              "WATCHING",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade400,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              widget.movieName,
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
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri('https://streamimdb.ru/embed/movie/${widget.imdbId}'),
                    // ── FIX 1: Remove custom headers — they confuse the embed ──
                  ),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,

                    // ── FIX 2: These two are the video rendering fix ──
                    hardwareAcceleration: true,
                    supportZoom: false,

                    // ── FIX 3: Let the page use its natural viewport ──
                    useWideViewPort: true,
                    loadWithOverviewMode: true,

                    // ── FIX 4: Desktop user agent loads better video players ──
                    userAgent:
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',

                    // ── FIX 5: Allow fullscreen video ──
                    allowsPictureInPictureMediaPlayback: true,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStop: (controller, url) {
                    if (mounted) setState(() => _isLoading = false);
                  },
                  onLoadError: (controller, url, code, message) {
                    if (mounted) setState(() => _isLoading = false);
                    debugPrint('WebView error [$code]: $message');
                  },
                  onConsoleMessage: (controller, message) {
                    debugPrint('JS Console: ${message.message}');
                  },
                ),
                if (_isLoading)
                  Container(
                    color: Colors.grey.shade900,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.green.shade400,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Loading movie...",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Info below player ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movieName,
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
                        "Full Movie",
                        style: TextStyle(
                          color: Colors.green.shade300,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "streamimdb.ru",
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