import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../data/models/channel_model.dart';
import '../theme/app_theme.dart';

class PlayerView extends StatefulWidget {
  final Channel channel;

  const PlayerView({super.key, required this.channel});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Tear down any previous controllers first (used on retry/reconnect).
    _chewieController?.dispose();
    await _videoController?.dispose();
    _chewieController = null;
    _videoController = null;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Re-resolving the URL freshly re-fetches the .m3u8 manifest rather
      // than reusing a stale/expired one.
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
      );

      await controller.initialize();

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        // Live-stream behaviour: no seek bar, no position/duration
        // timestamps, no scrubbing forward/backward — just play/pause,
        // volume, fullscreen, and a buffering spinner.
        isLive: true,
        allowPlaybackSpeedChanging: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryPurple,
          handleColor: AppTheme.primaryPurple,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white10,
        ),
        errorBuilder: (context, errorMessage) {
          return _StreamError(onRetry: _initializePlayer);
        },
      );

      if (!mounted) return;
      setState(() {
        _videoController = controller;
        _chewieController = chewie;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.channel.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Reconnect',
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _initializePlayer,
          ),
        ],
      ),
      body: Center(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: AppTheme.primaryPurple);
    }

    if (_hasError || _chewieController == null) {
      return _StreamError(onRetry: _initializePlayer);
    }

    final aspectRatio = _videoController!.value.aspectRatio == 0
        ? 16 / 9
        : _videoController!.value.aspectRatio;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}

/// Shared error state for both "failed to initialize" and chewie's own
/// in-player error callback, with a button to reconnect to the stream.
class _StreamError extends StatelessWidget {
  final VoidCallback onRetry;

  const _StreamError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Unable to play this stream. It may be offline.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reconnect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
