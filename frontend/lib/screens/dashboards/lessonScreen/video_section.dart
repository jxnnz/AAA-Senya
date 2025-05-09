import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoSection extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onSlowMotionPressed;
  final VoidCallback? onMirrorPressed;
  final double height;
  final double playbackSpeed;

  const VideoSection({
    super.key,
    required this.videoUrl,
    this.onSlowMotionPressed,
    this.onMirrorPressed,
    this.height = 200,
    this.playbackSpeed = 1.0,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  bool get isNetwork => widget.videoUrl.startsWith('http');

  @override
  void initState() {
    super.initState();

    _controller =
        isNetwork
            ? VideoPlayerController.network(widget.videoUrl)
            : VideoPlayerController.asset(widget.videoUrl);

    _controller.initialize().then((_) {
      setState(() => _isInitialized = true);
      _controller.setLooping(true);
      _controller.setVolume(0);
      _controller.play();
    });
  }

  @override
  void didUpdateWidget(covariant VideoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized && widget.playbackSpeed != oldWidget.playbackSpeed) {
      _controller.setPlaybackSpeed(widget.playbackSpeed);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // 🎥 Only video, no gray overlay
          SizedBox(
            width: double.infinity,
            height: widget.height,
            child:
                _isInitialized
                    ? VideoPlayer(_controller)
                    : const Center(child: CircularProgressIndicator()),
          ),

          // 🐢 Slow Motion Button
          if (widget.onSlowMotionPressed != null)
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: widget.onSlowMotionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.slow_motion_video),
                label: const Text("Slow"),
              ),
            ),

          // 📷 Mirror Button
          if (widget.onMirrorPressed != null)
            Positioned(
              bottom: 10,
              left: 10,
              child: IconButton(
                onPressed: widget.onMirrorPressed,
                icon: const Icon(Icons.camera_front, color: Colors.white),
                iconSize: 32,
                tooltip: "Open Mirror",
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                  shape: const CircleBorder(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
