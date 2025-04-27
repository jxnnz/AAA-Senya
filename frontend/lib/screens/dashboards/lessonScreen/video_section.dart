import 'package:flutter/material.dart';

class VideoSection extends StatelessWidget {
  final VoidCallback onSlowMotionPressed;
  final VoidCallback onMirrorPressed;

  const VideoSection({
    super.key,
    required this.onSlowMotionPressed,
    required this.onMirrorPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9, // standard video ratio
      child: Stack(
        children: [
          // Video Placeholder
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Colors.black26,
              ),
            ),
          ),

          // Slow Motion Button - Top Right
          Positioned(
            top: 10,
            right: 10,
            child: ElevatedButton.icon(
              onPressed: onSlowMotionPressed,
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
              icon: Icon(Icons.slow_motion_video),
              label: Text("Slow"),
            ),
          ),

          // Mirror Icon - Bottom Left
          Positioned(
            bottom: 10,
            left: 10,
            child: IconButton(
              onPressed: onMirrorPressed,
              icon: Icon(Icons.camera_front, color: Colors.white),
              iconSize: 32,
              tooltip: "Open Mirror",
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
                shape: CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
